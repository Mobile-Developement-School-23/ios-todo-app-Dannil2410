//
//  Color.swift
//  SwiftUIVersion
//
//  Created by Даниил Кизельштейн on 20.07.2023.
//

import SwiftUI

enum Colors {
    case supportSeparator
    case supportOverlay
    case labelPrimary
    case labelSecondary
    case labelTeritary
    case colorRed
    case colorGreen
    case colorBlue
    case colorGray
    case colorGrayLight
    case backPrimary
    case backSecondary

    var value: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {

            case .light:
                switch self {
                case .supportSeparator:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
                case .supportOverlay:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.06)
                case .labelPrimary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                case .labelSecondary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
                case .labelTeritary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                case .colorRed:
                    return UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
                case .colorGreen:
                    return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
                case .colorBlue:
                    return UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                case .colorGray:
                    return UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
                case .colorGrayLight:
                    return UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
                case .backPrimary:
                    return UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
                case .backSecondary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                }

            default:
                switch self {
                case .supportSeparator:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
                case .supportOverlay:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.32)
                case .labelPrimary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                case .labelSecondary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
                case .labelTeritary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
                case .colorRed:
                    return UIColor(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0)
                case .colorGreen:
                    return UIColor(red: 0.2, green: 0.84, blue: 0.29, alpha: 1.0)
                case .colorBlue:
                    return UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0)
                case .colorGray:
                    return UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
                case .colorGrayLight:
                    return UIColor(red: 0.28, green: 0.28, blue: 0.29, alpha: 1.0)
                case .backPrimary:
                    return UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
                case .backSecondary:
                    return UIColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1.0)
                }
            }
        }
    }

    var cgColor: CGColor {
        return self.value.cgColor
    }
}

