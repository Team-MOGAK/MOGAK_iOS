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

struct FeedComment {
    var profileImage: String
    var name: String
    var comment: String
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

extension FeedComment {
    static var data = [
        FeedComment(profileImage: "cuteBokdol", name: "엉엉이", comment: "우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"),
        FeedComment(profileImage: "cuteBokdol", name: "Nurin", comment: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!")
    ]
}
