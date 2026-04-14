# Login Form UI/UX Design Spec

## Overview
A responsive Login interface built with Flutter supporting both Mobile and Desktop aspect ratios.

## UI Structure
* **Mobile**: Single column overlay layout on top of the space background.
* **Desktop**: Split screen view (Space theme image on left 50%, Login form on right with deep dark background `0C071C`).

## Functional Requirements
* **Form Mode**: Đăng nhập (Sign In).
* **Header / Helper Texts**:
  - Tiêu đề chính: "SIGN IN"
  - Subtext: "Sign in with your email and password"
  - Điều hướng góc phải: "Don't have an account? Sign up"
* **Trao đổi dữ liệu (Input Fields)**:
  - **Email Field**: Kèm icon `mail`, hỗ trợ real-time validation, tự động check định dạng email hợp lệ. 
  - **Password Field**: Kèm icon `lock`, hỗ trợ hiện/ẩn mật khẩu thông qua nút `eye` toggle, tự động ẩn chữ dưới định dạng `****`. Ràng buộc không được để trống.
* **Hành động chính (CTA)**:
  - Nút "Sign In" sử dụng dải màu gradient tím/xanh ngọc.
  - Khi nhấp vào, nút sẽ tự vô hiệu hoá (disabled) và hiển thị Loading Spinner để chờ tác vụ bất đồng bộ.
  - Sau khi nộp thành công/thất bại, hiển thị thông báo Toast.

## Error Handling & Feedback
* **Validation**: Lỗi sẽ được highlight (viền đỏ) và hiển thị dòng text báo lỗi ngay bên dưới trường nhập liệu đang thao tác (Realtime).
* **Loading State**: Ngăn cấm nhấp lại nút khi form đang ở loading state.

## Navigation Patterns
* Duy trì các nút cho "Google" và "Facebook" social signons.
* Nút Terms and Conditions duy trì dưới cùng.
