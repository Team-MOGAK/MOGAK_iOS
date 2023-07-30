//
//  Locations.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/07/28.
//

import Foundation

struct Locations {
    var location: String
}

struct Categories {
    var category: String
}

extension Locations {
    static var data = [
        Locations(location: "서울특별시"),
        Locations(location: "경기도"),
        Locations(location: "세종특별자치시"),
        Locations(location: "대전광역시"),
        Locations(location: "광주광역시"),
        Locations(location: "대구광역시"),
        Locations(location: "부산광역시"),
        Locations(location: "울산광역시"),
        Locations(location: "경상남도"),
        Locations(location: "경상북도"),
        Locations(location: "전라남도"),
        Locations(location: "전라북도"),
        Locations(location: "충청남도"),
        Locations(location: "충청북도"),
        Locations(location: "강원도"),
        Locations(location: "제주도"),
        Locations(location: "독도/울릉도")
        
    ]
}

extension Categories {
    static var data = [
        Categories(category: "전체"),
        Categories(category: "자격증"),
        Categories(category: "대외활동"),
        Categories(category: "운동"),
        Categories(category: "인사이트"),
        Categories(category: "공모전"),
        Categories(category: "직무공부"),
        Categories(category: "산업분석"),
        Categories(category: "강연/강의"),
        Categories(category: "어학"),
        Categories(category: "프로젝트"),
        Categories(category: "스터디"),
        Categories(category: "기타"),
    ]
}
