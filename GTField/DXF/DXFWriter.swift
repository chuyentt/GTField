//
//  DXFWriter.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/19/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation

/// No overview available.
public enum DXFError: Error {
    
    /// No overview available.
    case cannotOpenFile
    /// No overview available.
    case cannotReadFile
    /// No overview available.
    case cannotWriteStream
    /// No overview available.
    case streamErrorHasOccurred(error: Error)
    /// No overview available.
    case unicodeDecoding
    /// No overview available.
    case cannotReadHeaderRow
    /// No overview available.
    case stringEncodingMismatch
    /// No overview available.
    case stringEndianMismatch
    
}

public class DXFWriter {
    
    public struct Configuration {
        
        public var newline: String
        
        internal init(newline: Newline) {
            switch newline {
                case .lf:
                    self.newline = String(LF)
                case .crlf:
                    self.newline = String(CR) + String(LF)
            }
        }
        
    }
    
    public enum Newline {
        
        /// "\n"
        case lf
        /// "\r\n"
        case crlf
        
    }
    
    public let stream: OutputStream
    public let configuration: Configuration
    fileprivate let writeScalar: ((UnicodeScalar) throws -> Void)
    
    fileprivate var isFirstRow: Bool = true
    fileprivate var isFirstField: Bool = true
    
    fileprivate init(
        stream: OutputStream,
        configuration: Configuration,
        writeScalar: @escaping ((UnicodeScalar) throws -> Void)) throws {
        
        self.stream = stream
        self.configuration = configuration
        self.writeScalar = writeScalar
        
        if stream.streamStatus == .notOpen {
            stream.open()
        }
        if stream.streamStatus != .open {
            throw DXFError.cannotOpenFile
        }
    }
    
    deinit {
        if stream.streamStatus == .open {
            stream.close()
        }
    }
    
}

extension DXFWriter {
    
    public convenience init(
        stream: OutputStream,
        newline: Newline = .lf
        ) throws {
        
        try self.init(stream: stream, codecType: UTF8.self, newline: newline)
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        newline: Newline = .lf
        ) throws where T.CodeUnit == UInt8 {
        
        let config = Configuration(newline: newline)
        try self.init(stream: stream, configuration: config) { (scalar: UnicodeScalar) throws in
            var error: DXFError? = nil
            codecType.encode(scalar) { (code: UInt8) in
                var code = code
                let count = stream.write(&code, maxLength: 1)
                if count != 1 {
                    error = DXFError.cannotWriteStream
                }
            }
            if let error = error {
                throw error
            }
        }
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        endian: Endian = .big,
        newline: Newline = .lf
        ) throws where T.CodeUnit == UInt16 {
        
        let config = Configuration(newline: newline)
        try self.init(stream: stream, configuration: config) { (scalar: UnicodeScalar) throws in
            var error: DXFError? = nil
            codecType.encode(scalar) { (code: UInt16) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                withUnsafeBytes(of: &code) { (buffer) -> Void in
                    let count = stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                                             maxLength: buffer.count)
                    if count != buffer.count {
                        error = DXFError.cannotWriteStream
                    }
                }
            }
            if let error = error {
                throw error
            }
        }
    }
    
    public convenience init<T: UnicodeCodec>(
        stream: OutputStream,
        codecType: T.Type,
        endian: Endian = .big,
        newline: Newline = .lf
        ) throws where T.CodeUnit == UInt32 {
        
        let config = Configuration(newline: newline)
        try self.init(stream: stream, configuration: config) { (scalar: UnicodeScalar) throws in
            var error: DXFError? = nil
            codecType.encode(scalar) { (code: UInt32) in
                var code = (endian == .big) ? code.bigEndian : code.littleEndian
                withUnsafeBytes(of: &code) { (buffer) -> Void in
                    let count = stream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                                             maxLength: buffer.count)
                    if count != buffer.count {
                        error = DXFError.cannotWriteStream
                    }
                }
            }
            if let error = error {
                throw error
            }
        }
    }
    
}

extension DXFWriter {
    
    public func beginNewRow() {
        isFirstField = true
    }
    
    public func write(field value: String, quoted: Bool = false) throws {
        if isFirstRow {
            isFirstRow = false
        } else {
            if isFirstField {
                try configuration.newline.unicodeScalars.forEach(writeScalar)
            }
        }
        
        if isFirstField {
            isFirstField = false
        }
        
        var value = value
        
        if quoted {
            value = value.replacingOccurrences(of: DQUOTE_STR, with: DQUOTE2_STR)
            try writeScalar(DQUOTE)
        }
        
        try value.unicodeScalars.forEach(writeScalar)
        
        if quoted {
            try writeScalar(DQUOTE)
        }
    }
    
    public func write(row values: [String], quotedAtIndex: ((Int) -> Bool) = { _ in false }) throws {
        beginNewRow()
        for (i, value) in values.enumerated() {
            try write(field: value, quoted: quotedAtIndex(i))
        }
    }
    
}
