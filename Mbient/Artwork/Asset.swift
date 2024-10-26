/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The data model for an asset.
*/

import SwiftUI

enum Asset: String, CaseIterable, Identifiable {
    case beach
    case botanist
    case camping
    case coffeeberry
    case creek
    case discovery
    case hillside
    case lab
    case lake
    case landing
    case ocean
    case park
    case poppy
    case samples
    case yucca

    var id: Self { self }

    var title: String {
        rawValue.capitalized
    }

    var landscapeImage: Image {
        Image(rawValue + "_landscape")
    }

    var portraitImage: Image {
        Image(rawValue + "_portrait")
    }

    var keywords: [String] {
        switch self {
        case .beach:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .camping:
            ["nature", "photography", "forest", "insects", "dark", "camping", "plants"]
        case .creek:
            ["creek", "nature", "photography", "plants", "petal", "flower"]
        case .hillside:
            ["hillside", "cliffs", "sea", "ocean", "waves", "surf", "rocks", "nature", "photography", "grass", "plants"]
        case .ocean:
            ["sea", "ocean", "nature", "photography", "waves", "island", "sky"]
        case .park:
            ["nature", "photography", "park", "cactus", "plants", "sky"]
        case .lake:
            ["nature", "photography", "water", "turtles", "animals", "reeds"]

        case .coffeeberry:
            ["animated", "animation", "plants", "coffeeberry"]
        case .yucca:
            ["animated", "animation", "plants", "yucca"]
        case .poppy:
            ["animated", "animation", "plants", "poppy"]
        case .samples:
            ["animated", "animation", "plants", "samples"]
        case .discovery:
            ["botanist", "discovery", "science", "animated", "animation", "character", "cave", "mushrooms", "fungus", "fungi", "plants"]
        case .lab:
            ["botanist", "science", "lab", "laboratory", "animated", "animation", "character", "window", "plants"]
        case .botanist:
            ["botanist", "science", "animated", "animation", "character", "rocks", "grass", "plants"]
        case .landing:
            ["botanist", "science", "animated", "animation", "character", "space", "planet"]
        }
    }

    static var lookupTable: [String: [Asset]] {
        var result: [String: [Asset]] = [:]
        for asset in allCases {
            for keyword in asset.keywords {
                result[keyword, default: []].append(asset)
            }
        }
        return result
    }
}

enum HomeCamera: String, CaseIterable, Identifiable, Hashable {
    case Front_Door
    case Garage_Doorbell
    case Parking
    case Frontyard_Left
    case Backyard_Left
    case Sideyard_Left
    case Sideyard_Right
    case Backyard_Right
    case Rooftop
    case Hallway_Indoor
    case Garage_Indoor

    var id: Self { self }

    var title: String {
        switch self {
        case .Front_Door:
            "Front Door"
        case .Garage_Doorbell:
            "Garage Door"
        case .Parking:
            "Parking"
        case .Frontyard_Left:
            "Frontyard Left"
        case .Backyard_Left:
            "Backyard Left"
        case .Sideyard_Left:
            "Sideyard Left"
        case .Sideyard_Right:
            "Sideyard Right"
        case .Backyard_Right:
            "Dining"
        case .Rooftop:
            "Rooftop"
        case .Hallway_Indoor:
            "Hallway"
        case .Garage_Indoor:
            "Garage"
        }
    }

    var StreamURL: String {
        switch self {
        case .Hallway_Indoor:
            "http://localhost:23424/cds/resource/1000000010001852/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=402bdf459aaa4e4c92035a690c1d677c"
            //"http://192.168.128.177:8089/hallway_indoor.m3u8"
        case .Garage_Indoor:
            "http://localhost:23424/cds/resource/1000000010001852/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=402bdf459aaa4e4c92035a690c1d677c"
            //"http://192.168.128.177:8089/garage_indoor.m3u8"
        case .Parking:
            "http://localhost:23424/cds/resource/1000000010001852/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=402bdf459aaa4e4c92035a690c1d677c"
            //"http://192.168.128.177:8089/parking.m3u8"
        case .Rooftop:
            "http://localhost:23424/cds/resource/1000000010001852/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=402bdf459aaa4e4c92035a690c1d677c"
            //"http://192.168.128.177:8089/rooftop.m3u8"
        case .Frontyard_Left:
            "http://localhost:23424/cds/resource/1000000010001852/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=402bdf459aaa4e4c92035a690c1d677c"
            //"http://192.168.128.177:8089/frontyard_left.m3u8"
        case .Backyard_Left:
            "http://localhost:23424/cds/resource/1000000010001852/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=402bdf459aaa4e4c92035a690c1d677c"
            //"http://192.168.128.177:8089/backyard_left.m3u8"
        case .Sideyard_Left:
            "http://localhost:23424/cds/resource/1000000010001215/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=f4d228f229784d8e8022d1fea67d28c2"
            //"http://192.168.128.177:8089/sideyard_left.m3u8"
        case .Sideyard_Right:
            "http://localhost:23424/cds/resource/1000000010001215/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=f4d228f229784d8e8022d1fea67d28c2"
            //"http://192.168.128.177:8089/sideyard_right.m3u8"
        case .Backyard_Right:
            "http://localhost:23424/cds/resource/1000000010001215/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=f4d228f229784d8e8022d1fea67d28c2"
            //"http://192.168.128.177:8089/backyard_right.m3u8"
        case .Garage_Doorbell:
            "http://localhost:23424/cds/resource/1000000010001215/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=f4d228f229784d8e8022d1fea67d28c2"
            //"http://192.168.128.177:8089/garage_doorbell.m3u8"
        case .Front_Door:
            "http://localhost:23424/cds/resource/1000000010001215/MEDIA_ITEM/HLS-0/ORIGINAL.m3u8?profile=html5&clientName=MediaBrowser&authToken=f4d228f229784d8e8022d1fea67d28c2"
            //"http://192.168.128.177:8089/front_door.m3u8"
            /*
        case .Hallway_Indoor:
            "rtsp://192.168.128.177:54135/c82e4a660a7fd6fe"
        case .Garage_Indoor:
            "rtsp://192.168.128.177:54021/ca85044a5612d161"
        case .Parking:
            "rtsp://192.168.128.177:62213/f3bdf8be3e1dcf6e"
        case .Rooftop:
            "rtsp://192.168.128.177:51132/eae5a3344e801066"
        case .Frontyard_Left:
            "rtsp://192.168.128.177:49795/104cc5aa28d04086"
        case .Backyard_Left:
            "rtsp://192.168.128.177:51175/98533ccff6efcb4b"
        case .Sideyard_Left:
            "rtsp://192.168.128.177:51203/644085e005c425ae"
        case .Sideyard_Right:
            "rtsp://192.168.128.177:56774/0090ea97d120730b"
        case .Backyard_Right:
            "rtsp://192.168.128.177:55069/b4f6a47ffc8ba910"
        case .Garage_Doorbell:
            "rtsp://192.168.128.177:51236/a27473e7abb64002"
        case .Front_Door:
            "rtsp://192.168.128.177:51283/00cb27e3ed420a25"
             */
        }
    }

    var keywords: [String] {
        switch self {
        case .Hallway_Indoor:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Garage_Indoor:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Parking:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Rooftop:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Frontyard_Left:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Backyard_Left:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Sideyard_Left:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Sideyard_Right:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Backyard_Right:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Garage_Doorbell:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Front_Door:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        }
    }
    static var lookupTable: [String: [HomeCamera]] {
        var result: [String: [HomeCamera]] = [:]
        for camera in allCases {
            for keyword in camera.keywords {
                result[keyword, default: []].append(camera)
            }
        }
        return result
    }
}


enum TVChannels: String, CaseIterable, Identifiable {
    case Channel1
    case Channel2
    case Channel3
    case Channel4
    case Channel5
    case Channel6
    case Channel7
    case Channel8
    case Channel9
    case Channel10
    case Channel11
    case Channel12
    case Channel13
    case Channel14
    
    var id: Self { self }

    var title: String {
        switch self {
        case .Channel1:
            "MTV LEBANON"
        case .Channel2:
            "AL ARABIYA"
        case .Channel3:
            "CNN INTERNATIONAL"
        case .Channel4:
            "SKYNEWS ARABIA"
        case .Channel5:
            "AL JAZEERA"
        case .Channel6:
            "BBC NEWS"
        case .Channel7:
            "TF1"
        case .Channel8:
            "FRANCE 2"
        case .Channel9:
            "AL JAZEERA MUBASHER"
        case .Channel10:
            "AL JAZEERA ENGLISH"
        case .Channel11:
            "AL JAZZEERA DOCUMENTARY"
        case .Channel12:
            "AL HADATH"
        case .Channel13:
            "Al HURRA"
        case .Channel14:
            "BBC ARABIC"
        }
    }

    var StreamURL: String {
        switch self {
            case .Channel1:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/110/hls/master.m3u8"
            case .Channel2:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/105/hls/master.m3u8"
            case .Channel3:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/111/hls/master.m3u8"
            case .Channel4:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/112/hls/master.m3u8"
            case .Channel5:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/101/hls/master.m3u8"
            case .Channel6:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/113/hls/master.m3u8"
            case .Channel7:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/100/hls/master.m3u8"
            case .Channel8:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/108/hls/master.m3u8"
            case .Channel9:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/102/hls/master.m3u8"
            case .Channel10:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/103/hls/master.m3u8"
            case .Channel11:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/104/hls/master.m3u8"
            case .Channel12:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/106/hls/master.m3u8"
            case .Channel13:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/107/hls/master.m3u8"
            case .Channel14:
                "http://192.168.128.177:8089/devices/M3U-FavoriteTVChannels/channels/109/hls/master.m3u8"
            }
    }
    
    var Image: String {
        switch self {
        case .Channel1:
            "MTV_LEBANON"
        case .Channel2:
            "AL_ARABIYA"
        case .Channel3:
            "CNN"
        case .Channel4:
            "SKYNEWS_ARABIA"
        case .Channel5:
            "AL_JAZEERA"
        case .Channel6:
            "BBC_NEWS"
        case .Channel7:
            "TF1"
        case .Channel8:
            "France_2"
        case .Channel9:
            "Al_JAZEERA_MUBASHER"
        case .Channel10:
            "AL_JAZEERA_ENGLISH"
        case .Channel11:
            "AL_JAZZEERA_DOCUMENTARY"
        case .Channel12:
            "AL_HADATH"
        case .Channel13:
            "Al_HURRA"
        case .Channel14:
            "BBC_ARABIC"
            }
    }

    var keywords: [String] {
        switch self {
        case .Channel1:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel2:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel3:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel4:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel5:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel6:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel7:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel8:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel9:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel10:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel11:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel12:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel13:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel14:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        }
    }
    
}

enum StreamServer: String, CaseIterable, Identifiable {
    case Local
    case TailScale
    case Web
    
    var id: Self { self }
    
    var ServerIP: String{
        switch self {
        case .Local:
            "192.168.128.177:8089"
        case .TailScale:
            "100.88.163.25:8089"
        case .Web:
            "100.88.163.25:8089"
        }
    }
}
    
enum Channels: String, CaseIterable, Identifiable {
    case HomeCams
    case NewsChannels
    case SlingTV
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .HomeCams:
            "Home Cameras"
        case .NewsChannels:
            "News Channels"
        case .SlingTV:
            "Sling TV"
        }
    }
        
    var M3UURL: String {
        switch self {
        case .HomeCams:
            "/devices/M3U-HomeCameras/channels.m3u"
        case .NewsChannels:
            "/devices/M3U-FavoriteTVChannels/channels.m3u"
        case .SlingTV:
            "/devices/TVE-slingtv/channels.m3u"
        }
    }
}

enum TVApps: String, CaseIterable, Identifiable {
    case Channel1
    case Channel2
    case Channel3
    case Channel4
    case Channel5

    var id: Self { self }

    var title: String {
        switch self {
        case .Channel1:
            "Netflix"
        case .Channel2:
            "HULU"
        case .Channel3:
            "SHAHID"
        case .Channel4:
            "OSN+"
        case .Channel5:
            "STARZPLAY"
        }
    }

    var StreamURL: String {
        switch self {
            case .Channel1:
                "NETFLIX_LINK"
            case .Channel2:
                "HULU_LINK"
            case .Channel3:
                "SHAHID_LINK"
            case .Channel4:
                "OSN_LINK"
            case .Channel5:
                "STARZPLAY_LINK"
            }
    }
    
    var Image: String {
        switch self {
        case .Channel1:
            "Netflix"
        case .Channel2:
            "HULU"
        case .Channel3:
            "SHAHID"
        case .Channel4:
            "OSN+"
        case .Channel5:
            "STARZPLAY"
            }
    }

    var keywords: [String] {
        switch self {
        case .Channel1:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel2:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel3:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel4:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        case .Channel5:
            ["nature", "photography", "sea", "ocean", "beach", "sunset", "sea", "waves", "boats", "sky"]
        }
    }
    static var lookupTable: [String: [TVApps]] {
        var result: [String: [TVApps]] = [:]
        for tvapp in allCases {
            for keyword in tvapp.keywords {
                result[keyword, default: []].append(tvapp)
            }
        }
        return result
    }
}
