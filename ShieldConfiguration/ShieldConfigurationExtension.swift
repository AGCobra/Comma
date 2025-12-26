//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Albert Chehebar on 12/8/25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    // MARK: - Application Shields

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Check if currently unlocked
        if AppGroupManager.shared.isUnlocked {
            return ShieldConfiguration()
        }
        return createCommaShield()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        if AppGroupManager.shared.isUnlocked {
            return ShieldConfiguration()
        }
        return createCommaShield()
    }

    // MARK: - Web Domain Shields

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        if AppGroupManager.shared.isUnlocked {
            return ShieldConfiguration()
        }
        return createCommaShield()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        if AppGroupManager.shared.isUnlocked {
            return ShieldConfiguration()
        }
        return createCommaShield()
    }

    // MARK: - Shield Configuration

    private func createCommaShield() -> ShieldConfiguration {
        // Dark gray background
        let backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)

        // Shield content
        let icon = UIImage(systemName: "pause.circle.fill")
        let title = ShieldConfiguration.Label(
            text: "One Breath",
            color: .white
        )
        let subtitle = ShieldConfiguration.Label(
            text: "A notification will guide you to breathe",
            color: UIColor(white: 0.7, alpha: 1.0)
        )

        // Primary button - dismiss shield so user can switch to Comma
        let primaryButton = ShieldConfiguration.Label(
            text: "Take a breath",
            color: .white
        )

        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: backgroundColor,
            icon: icon,
            title: title,
            subtitle: subtitle,
            primaryButtonLabel: primaryButton,
            primaryButtonBackgroundColor: UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1.0),
            secondaryButtonLabel: nil
        )
    }
}
