import UIKit
import SafepayDropsSDK

final class PayerAuthViewController: UIViewController {

    private let configuration: SafepayPayerAuthenticationConfiguration
    private var payerAuthView: SafepayPayerAuthenticationView!

    private let eventLogTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 8
        tv.layer.masksToBounds = true
        return tv
    }()

    // MARK: - Init

    init(configuration: SafepayPayerAuthenticationConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payer Auth"
        view.backgroundColor = .systemBackground

        payerAuthView = SafepayPayerAuthenticationView()
        payerAuthView.delegate = self

        setupLayout()
        payerAuthView.configure(configuration)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            payerAuthView.dispose()
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        payerAuthView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(payerAuthView)

        let logTitleLabel = UILabel()
        logTitleLabel.text = "Event Log"
        logTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        logTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTitleLabel)

        eventLogTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventLogTextView)

        NSLayoutConstraint.activate([
            payerAuthView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            payerAuthView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            payerAuthView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            payerAuthView.bottomAnchor.constraint(equalTo: logTitleLabel.topAnchor, constant: -12),

            logTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            eventLogTextView.topAnchor.constraint(equalTo: logTitleLabel.bottomAnchor, constant: 8),
            eventLogTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventLogTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            eventLogTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            eventLogTextView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }

    // MARK: - Event log

    private func appendLog(kind: String, message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let line = "[\(timestamp)] \(kind): \(message)"
        let current = eventLogTextView.text ?? ""
        eventLogTextView.text = current.isEmpty ? line : "\(line)\n\n\(current)"
    }
}

// MARK: - SafepayPayerAuthenticationDelegate

extension PayerAuthViewController: SafepayPayerAuthenticationDelegate {
    func onPayerAuthenticationSuccess(data: PayerAuthenticationSuccessData) {
        appendLog(kind: "success", message: "\(data)")
    }

    func onPayerAuthenticationFailure(data: PayerAuthenticationErrorData) {
        appendLog(kind: "failure", message: "\(data)")
    }

    func onPayerAuthenticationRequired(data: PayerAuthenticationData) {
        appendLog(kind: "required", message: "\(data)")
    }

    func onPayerAuthenticationFrictionless(data: PayerAuthenticationData) {
        appendLog(kind: "frictionless", message: "\(data)")
    }

    func onPayerAuthenticationUnavailable(data: PayerAuthenticationData) {
        appendLog(kind: "unavailable", message: "\(data)")
    }

    func onSafepayError(error: SafepayErrorData) {
        appendLog(kind: "safepay-error", message: "\(error)")
    }
}
