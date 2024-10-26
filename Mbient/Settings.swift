
import SwiftUI
import AVKit
import Foundation

// MARK: - Models
struct CollectionItem: Codable, Identifiable {
    let url: String
    let id: String
    let order: Int
    let name: String
}

class TopMenu: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: String
    let order: Int
    
    init(name: String, url: String, order: Int) {
        self.name = name
        self.url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        self.order = order
    }
    
    static var settings: TopMenu {
        return TopMenu(name: "Settings", url: "Settings", order: Int.max)
    }
    
    static func == (lhs: TopMenu, rhs: TopMenu) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Collection Manager
class CollectionManager: ObservableObject {
    @Published var menuItems: [TopMenu] = []
    private let fileURL: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("Collection.json")
        loadCollection()
    }
    
    func loadCollection() {
        do {
            let data = try Data(contentsOf: fileURL)
            let collectionItems = try JSONDecoder().decode([CollectionItem].self, from: data)
            
            menuItems = collectionItems.map { item in
                let fullUrl = item.url.hasPrefix("http") ? item.url : "http://" + StreamServer.Local.ServerIP + item.url
                return TopMenu(name: item.name, url: fullUrl, order: item.order)
            }.sorted(by: { $0.order < $1.order })
            
            menuItems.append(TopMenu.settings)
            print("Successfully loaded collection from: \(fileURL.path)")
            
        } catch {
            print("Error loading collection: \(error)")
            menuItems = [TopMenu.settings]
        }
    }
    
    func saveCollection() {
        do {
            let items = menuItems.filter { $0.name != "Settings" }.enumerated().map { index, item in
                CollectionItem(url: item.url, id: UUID().uuidString, order: index, name: item.name)
            }
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: [.atomicWrite])
            print("Successfully saved collection to: \(fileURL.path)")
        } catch {
            print("Error saving collection: \(error)")
        }
    }
}

// MARK: - Category Store
class CategoryStore: ObservableObject {
    @Published var categories: [Category] {
        didSet {
            save()
        }
    }
    
    private let fileURL: URL
    
    init() {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        fileURL = cachesDirectory.appendingPathComponent("Collection.json")
        
        if let data = try? Data(contentsOf: fileURL),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decodedCategories.sorted(by: { $0.order < $1.order })
        } else {
            categories = []
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: fileURL, options: [.atomic])
            print("Successfully saved to: \(fileURL.path)")
        } catch {
            print("Error saving categories: \(error)")
        }
    }
    
    func updateOrder() {
        for (index, var category) in categories.enumerated() {
            category.order = index
            if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) {
                categories[categoryIndex] = category
            }
        }
    }
}

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var url: String
    var order: Int
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Views
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryStore = CategoryStore()
    @StateObject private var settingsManager = SettingsManager()
    @State private var selectedCategory: Category?
    @State private var showingAddSheet = false
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    @EnvironmentObject private var collectionManager: CollectionManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Authorization")) {
                    SecureField("Authorization Token", text: $settingsManager.settings.authorizationCode)
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: settingsManager.settings.authorizationCode) {
                                settingsManager.saveSettings()
                            }
                }
                
                Section(header: Text("Categories")) {
                    ForEach(categoryStore.categories) { category in
                        CategoryRowView(category: category)
                            .focusable(true)
                            .onLongPressGesture {
                                selectedCategory = category
                            }
                            .contextMenu {
                                Button("Edit") {
                                    selectedCategory = category
                                }
                                Button("Delete", role: .destructive) {
                                    categoryToDelete = category
                                    showingDeleteAlert = true
                                }
                            }
                    }
                    .onMove { source, destination in
                        categoryStore.categories.move(fromOffsets: source, toOffset: destination)
                        categoryStore.updateOrder()
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Add Category") {
                        showingAddSheet = true
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        collectionManager.loadCollection()
                    }
                    .padding(.trailing, 8)
                    
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        }
        .sheet(item: $selectedCategory) { category in
            EditCategoryView(category: category, categoryStore: categoryStore)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCategoryView(categoryStore: categoryStore)
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert, presenting: categoryToDelete) { category in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteCategory(category)
            }
        } message: { category in
            Text("Are you sure you want to delete '\(category.name)'?")
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        categoryStore.categories.remove(atOffsets: offsets)
        categoryStore.updateOrder()
    }
    
    private func deleteCategory(_ category: Category) {
        if let index = categoryStore.categories.firstIndex(of: category) {
            categoryStore.categories.remove(at: index)
            categoryStore.updateOrder()
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var categoryStore: CategoryStore
    @State private var name = ""
    @State private var url = ""
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, url
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $name)
                    .focused($focusedField, equals: .name)
                TextField("Category URL", text: $url)
                    .focused($focusedField, equals: .url)
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newCategory = Category(
                            id: UUID(),
                            name: name,
                            url: url,
                            order: categoryStore.categories.count
                        )
                        categoryStore.categories.append(newCategory)
                        dismiss()
                    }
                    .disabled(name.isEmpty || url.isEmpty)
                }
            }
        }
    }
}

struct EditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var url: String
    @ObservedObject var categoryStore: CategoryStore
    let category: Category
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, url
    }
    
    init(category: Category, categoryStore: CategoryStore) {
        self.category = category
        self.categoryStore = categoryStore
        _name = State(initialValue: category.name)
        _url = State(initialValue: category.url)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $name)
                    .focused($focusedField, equals: .name)
                TextField("Category URL", text: $url)
                    .focused($focusedField, equals: .url)
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let index = categoryStore.categories.firstIndex(where: { $0.id == category.id }) {
                            var updatedCategory = category
                            updatedCategory.name = name
                            updatedCategory.url = url
                            categoryStore.categories[index] = updatedCategory
                        }
                        dismiss()
                    }
                    .disabled(name.isEmpty || url.isEmpty)
                }
            }
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.headline)
            Text(category.url)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Model
struct AppSettings: Codable {
    var authorizationCode: String
    
    static let defaultSettings = AppSettings(authorizationCode: "")
}

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    @Published var settings: AppSettings
    private let fileURL: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("settings.json")
        
        if let data = try? Data(contentsOf: fileURL),
           let loadedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = loadedSettings
        } else {
            settings = AppSettings.defaultSettings
        }
    }
    
    func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: fileURL, options: [.atomicWrite])
            print("Successfully saved settings to: \(fileURL.path)")
        } catch {
            print("Error saving settings: \(error)")
        }
    }
}
