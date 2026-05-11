import UIKit
import SafepayDropsSDK

final class SetupViewController: UIViewController {

    // MARK: - Environment

    private let environments: [SafepayEnvironment] = [.local, .development, .sandbox, .production]

    private lazy var environmentControl: UISegmentedControl = {
        let items = ["local", "dev", "sandbox", "prod"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 2
        return control
    }()

    // MARK: - Fields

    private let authTokenField = LabeledField(label: "Auth Token *", placeholder: "Bearer token")
    private let trackerField = LabeledField(label: "Tracker *", placeholder: "track_xxx")
    private let ddcJwtField = LabeledField(label: "DDC JWT *", placeholder: "JWT from Safepay API")
    private let ddcUrlField = LabeledField(label: "DDC URL *", placeholder: "https://centinelapistag...")
    private let streetField = LabeledField(label: "Street", placeholder: "123 Main Street")
    private let cityField = LabeledField(label: "City", placeholder: "Karachi")
    private let countryField = LabeledField(label: "Country", placeholder: "PK")

    private let doCaptureRow = ToggleRow(label: "Do Capture")
    private let doCardOnFileRow = ToggleRow(label: "Do Card on File")

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemRed
        l.font = .systemFont(ofSize: 14)
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private lazy var openButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Open Payer Auth Demo", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(openDemo), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setup"
        view.backgroundColor = .systemBackground

        setupLayout()
        setupDefaults()

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Layout

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Payer Auth Demo"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Fill in the fields from your Safepay API response, then tap Open."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        let envLabel = makeCaption("Environment")

        let cityCountryRow = UIStackView(arrangedSubviews: [cityField, countryField])
        cityCountryRow.axis = .horizontal
        cityCountryRow.spacing = 12
        cityCountryRow.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            envLabel,
            environmentControl,
            authTokenField,
            trackerField,
            ddcJwtField,
            ddcUrlField,
            streetField,
            cityCountryRow,
            doCaptureRow,
            doCardOnFileRow,
            errorLabel,
            openButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            openButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupDefaults() {
        streetField.textField.text = "123 Main Street"
        cityField.textField.text = "Karachi"
        countryField.textField.text = "PK"
    }

    // MARK: - Actions

    @objc private func openDemo() {
        let authToken = authTokenField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let tracker = trackerField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let ddcJwt = ddcJwtField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let ddcUrl = ddcUrlField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !authToken.isEmpty, !tracker.isEmpty, !ddcJwt.isEmpty, !ddcUrl.isEmpty else {
            errorLabel.text = "Auth token, tracker, DDC JWT, and DDC URL are required."
            errorLabel.isHidden = false
            return
        }
        errorLabel.isHidden = true

        let configuration = SafepayPayerAuthenticationConfiguration(
            environment: environments[environmentControl.selectedSegmentIndex],
            authToken: authToken,
            tracker: tracker,
            deviceDataCollectionJWT: ddcJwt,
            deviceDataCollectionURL: ddcUrl,
            billing: BillingAddress(
                street1: streetField.textField.text?.trimmingCharacters(in: .whitespaces) ?? "",
                city: cityField.textField.text?.trimmingCharacters(in: .whitespaces) ?? "",
                country: countryField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
            ),
            authorizationOptions: AuthorizationOptions(
                doCapture: doCaptureRow.toggle.isOn,
                doCardOnFile: doCardOnFileRow.toggle.isOn
            )
        )

        navigationController?.pushViewController(
            PayerAuthViewController(configuration: configuration),
            animated: true
        )
    }

    // MARK: - Helpers

    private func makeCaption(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        return l
    }
}

// MARK: - LabeledField

private final class LabeledField: UIView {
    let textField: UITextField

    init(label: String, placeholder: String) {
        textField = UITextField()
        super.init(frame: .zero)

        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 12)
        labelView.textColor = .secondaryLabel

        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no

        let stack = UIStackView(arrangedSubviews: [labelView, textField])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }
}

// MARK: - ToggleRow

private final class ToggleRow: UIView {
    let toggle = UISwitch()

    init(label: String) {
        super.init(frame: .zero)

        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 16)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [labelView, spacer, toggle])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }
}
