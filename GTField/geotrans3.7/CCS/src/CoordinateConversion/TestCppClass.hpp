//
//  TestCppClass.hpp
//  Pods
//
//  Created by Chuyen Trung Tran on 2/20/17.
//
//

#ifndef TestCppClass_hpp
#define TestCppClass_hpp

#include <stdio.h>

#include <string>

class TestCppClass {
public:
    TestCppClass();
    TestCppClass(const std::string &title);
    ~TestCppClass();
    
public:
    void setTitle(const std::string &title);
    const std::string &getTtile();
    
private:
    std::string m_title;
};

#endif /* TestCppClass_hpp */
