import UIKit

class AlertBuilder: NSObject {
    let title: String
    let message: String
    let defaultAction: AlertAction?
    let discardAction: AlertAction?
    let cancelAction: AlertAction?
    let image: UIImage?
    var dismissCompletion: (() -> ())?
    
    init(_ title: String, _ message: String) {
        self.title = title
        self.message = message
        self.defaultAction = nil
        self.cancelAction = nil
        self.discardAction = nil
        self.image = nil
    }
    init(_ title: String, _ message: String, _ defaultAction: AlertAction) {
        self.title = title
        self.message = message
        self.defaultAction = defaultAction
        self.cancelAction = nil
        self.discardAction = nil
        self.image = nil
    }
    init(_ image: UIImage, title: String, _ message: String, _ defaultAction: AlertAction) {
        self.title = title
        self.message = message
        self.defaultAction = defaultAction
        self.cancelAction = nil
        self.discardAction = nil
        self.image = image
    }
    init(_ title: String, _ message: String, _ defaultAction: AlertAction, _ cancelAction: AlertAction) {
        self.title = title
        self.message = message
        self.defaultAction = defaultAction
        self.cancelAction = cancelAction
        self.discardAction = nil
        self.image = nil
    }
    init(_ title: String, _ message: String, _ defaultAction: AlertAction, _ cancelAction: AlertAction, _ discardAction:AlertAction) {
        self.title = title
        self.message = message
        self.defaultAction = defaultAction
        self.cancelAction = cancelAction
        self.discardAction = discardAction
        self.image = nil
    }
    
    var controller: UIAlertController {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        if cancelAction != nil {
            alert.addAction(UIAlertAction(title: cancelAction!.text, style: .cancel, handler: {
                (uiAlertAction) in
                self.cancelAction?.action?()
            }))
        }
        if defaultAction != nil {
            alert.addAction(UIAlertAction(title: defaultAction!.text, style: .default, handler: {
                (uiAlertAction) in
                self.defaultAction?.action?()
            }))
        }
        if discardAction != nil{
            alert.addAction(UIAlertAction(title: discardAction!.text, style: .destructive, handler: {
                (uiAlertAction) in
                self.discardAction?.action?()
            }))
        }
        if image != nil {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 270 * 0.4268))
            imageView.image = image
            alert.view.addSubview(imageView)
        }
        return alert
    }
    func show(_ vc: UIViewController) {
        vc.present(controller, animated: true, completion: nil)
    }
    func dismiss() {
        controller.dismiss(animated: false, completion: {
            self.dismissCompletion?()
        })
    }
}

struct AlertAction {
    let action: (() -> ())?
    let text: String
    
    init (_ action: (() -> ())?, _ text: String) {
        self.action = action
        self.text = text
    }
}
