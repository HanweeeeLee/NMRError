//
//  NMRErrorManager.swift
//  Not My Responsibility!!!
//
//  Created by hanwe lee on 2021/03/12.
//
import Foundation

enum OwnErrorCode: Int {
    case noError = -1
    //You can add or change types!
}

enum ErrorFrom {
    case server
    case network
    //You can add or change types!
}

enum NMRErrorType {
    case ownErr
    case otherSideErr
}

protocol NMRDetailErrorPtorocol {
}

protocol NMRErrorProtocol: LocalizedError {
    var errType: NMRErrorType { get }
    var rawErrorCode: Int { get }
}



struct OwnDetailErrorInfomation: NMRDetailErrorPtorocol {
    var errorCode: OwnErrorCode
}

struct OtherSideDetailErrorInfomation: NMRDetailErrorPtorocol {
    var errorCode: Int
    var from: ErrorFrom
    var errorDescription: String
}

struct NMRError: NMRErrorProtocol, Equatable {
    var rawErrorCode: Int
    var errType: NMRErrorType = .ownErr
    var detailErrorInfo: NMRDetailErrorPtorocol? = nil
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String = ""
    
    static func == (lhs: NMRError, rhs: NMRError) -> Bool {
        if (lhs.rawErrorCode == rhs.rawErrorCode) && (lhs.errType == rhs.errType) {
            switch lhs.errType {
            case .ownErr:
                return true
            case .otherSideErr:
                guard let lhsDetailInfo = (lhs.detailErrorInfo as? OtherSideDetailErrorInfomation) else {
                    return false
                }
                guard let rhsDetailInfo = (rhs.detailErrorInfo as? OtherSideDetailErrorInfomation) else {
                    return false
                }
                if lhsDetailInfo.from == rhsDetailInfo.from {
                    return true
                }
                else {
                    return false
                }
            }
        }
        else {
            return false
        }
    }
    
    init(type: NMRErrorType, detailErrorInfo: NMRDetailErrorPtorocol) {
        self.detailErrorInfo = detailErrorInfo
        switch type {
        case .ownErr:
            guard let info = (detailErrorInfo as? OwnDetailErrorInfomation) else {
                print("your detailErrorInfo is wrong")
                self.rawErrorCode = -1
                return
            }
            self.rawErrorCode = info.errorCode.rawValue
            self._description = NMRError.getErrorMessage(errorCode: info.errorCode)
            break
        case .otherSideErr:
            guard let info = (detailErrorInfo as? OtherSideDetailErrorInfomation) else {
                print("your detailErrorInfo is wrong")
                self.rawErrorCode = -1
                return
            }
            self.rawErrorCode = info.errorCode
            self._description = info.errorDescription + "\n[\(self.rawErrorCode)]"
            break
        }
    }
    
    static func getErrorMessage(errorCode: OwnErrorCode) -> String {
        var resultValue:String = ""
        let message: String = NMRError.getLocalizedKeyFromErrorCode(errorCode: errorCode).localizedForNMRError
        resultValue = "\(message)" + "\n" + "[\(errorCode.rawValue)]"
        return resultValue
    }
    
    private static func getLocalizedKeyFromErrorCode(errorCode: OwnErrorCode) -> String {
        var returnValue: String = ""
        switch errorCode {
        case .noError:
            returnValue = "" //todo localized mapping define string
            break
        }
        return returnValue
    }
    
    
}


extension String {
    var localizedForNMRError: String {
        UserDefaults.standard.set(NSLocale.current.languageCode, forKey: "i18n_language")
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
