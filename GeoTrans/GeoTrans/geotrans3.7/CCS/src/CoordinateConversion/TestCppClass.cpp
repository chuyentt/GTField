//
//  TestCppClass.cpp
//  Pods
//
//  Created by Chuyen Trung Tran on 2/20/17.
//
//

#include "TestCppClass.hpp"

TestCppClass::TestCppClass() {}
TestCppClass::TestCppClass(const std::string &title): m_title(title) {}
TestCppClass::~TestCppClass() {}
void TestCppClass::setTitle(const std::string &title)
{
    m_title = title;
}
const std::string &TestCppClass::getTtile()
{
    return m_title;
}
