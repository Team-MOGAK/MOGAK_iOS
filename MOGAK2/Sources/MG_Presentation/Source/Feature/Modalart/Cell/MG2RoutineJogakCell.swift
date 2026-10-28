//
//  MG2RoutineJogakCell.swift
//  MOGAK
//

import UIKit

/// 루틴 조각 칸: 모각 색 태그에 루틴 요일.
final class MG2RoutineJogakCell: MG2JogakCell {
    static let routineIdentifier: String = "MG2RoutineJogakCell"

    func configure(badgeText: String, title: String, color: String) {
        configure(title: title)
        tagLabel.configure(text: badgeText, moak: DS.Moak.from(hex: color))
        tagLabel.isHidden = false
        contentView.accessibilityLabel = "\(title) 조각, 루틴 \(badgeText)"
    }
}
