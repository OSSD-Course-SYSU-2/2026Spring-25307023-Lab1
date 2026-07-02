#!/usr/bin/env python3
"""
Git 开发者生态演示 - Hello World 程序

该程序演示了 Python 基础功能，同时作为 Git 版本控制的示例项目。
"""

def greet(name: str) -> str:
    """生成问候语"""
    return f"Hello, {name}! Welcome to Git Dev Ecosystem."

def display_info():
    """显示项目信息"""
    info = {
        "project": "Git Dev Ecosystem Demo",
        "version": "1.0.0",
        "language": "Python",
        "purpose": "Demonstrate Git version control ecosystem"
    }
    for key, value in info.items():
        print(f"  {key}: {value}")

if __name__ == "__main__":
    print("=" * 50)
    print("  Git 开发者生态演示程序")
    print("=" * 50)
    display_info()
    print()
    print(greet("Developer"))
    print("=" * 50)
