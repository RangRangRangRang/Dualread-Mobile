# EpubReader

Ứng dụng Android viết bằng Flutter để đọc sách định dạng EPUB và quản lý sách theo album.

Bài tập lớn môn **Lập trình thiết bị di động**, Trường Đại học Phenikaa, học kỳ 1 năm học 2026 - 2027.

## Thông tin nhóm

- Lớp: N02
- Nhóm: 3
- Repository: `2026_2027_1_1_LTTBDD_N02_Nhom_3`

| STT | MSSV | Họ và tên | Vai trò | Phần việc chính |
|---|---|---|---|---|
| 1 | 23010721 | Lê Trường Giang | Nhóm trưởng |
| 2 | 23010446 | Nguyễn Quang Huy | Thành viên |
| 3 | 23010412 | Nguyễn Minh Tùng | Thành viên |

## Cài đặt nhanh (Android)

Tải file APK: [EpubReader.apk](https://github.com/RangRangRangRang/2026_2027_1_1_LTTBDD_N02_Nhom_3/releases/download/v1.0/EpubReader.apk)

Hoặc vào trang [Releases](https://github.com/RangRangRangRang/2026_2027_1_1_LTTBDD_N02_Nhom_3/releases/latest) và tải file `EpubReader.apk` trong mục Assets.

1. Tải file về điện thoại hoặc máy ảo Android.
2. Mở file, nếu máy hỏi thì cho phép cài ứng dụng từ nguồn này.
3. Cài đặt và mở ứng dụng EpubReader.
4. Chuẩn bị sẵn một file sách `.epub` trong máy để dùng chức năng Thêm EPUB.

Nếu máy đang có bản ứng dụng chạy từ môi trường lập trình (`flutter run`), hãy gỡ bản đó trước khi cài APK.

## Chức năng

**Thư viện**
- Thêm sách từ file `.epub` trong máy
- Tìm kiếm theo tên sách hoặc tác giả
- Xóa sách (có hỏi xác nhận)
- Chọn ngày dự định đọc xong bằng DatePicker
- Hiển thị trạng thái đọc: chưa đọc, hoặc đang đọc đến chương nào
- Thống kê: tổng số sách, đang đọc, chưa đọc, số album, số sách theo tác giả

**Đọc sách**
- Đọc theo từng chương, chuyển chương bằng nút Trước/Sau
- Mục lục để nhảy tới chương bất kỳ
- Chỉnh cỡ chữ, chế độ nền tối
- Nhớ chương đang đọc, mở lại sách đúng chương cũ
- Phát âm thanh khi chuyển chương
- Thanh công cụ tự ẩn khi đọc: ẩn sau 3 giây hoặc khi vuốt đọc xuống, chạm vào chữ để hiện lại

**Album**
- Tạo, đổi tên, xóa album (xóa album không xóa sách)
- Thêm sách vào album, gỡ sách khỏi album
- Mở sách trực tiếp từ album

**Chung**
- Hai ngôn ngữ Anh và Việt, đổi bằng nút `EN | VI` trên thanh tiêu đề, ngôn ngữ được nhớ cho lần mở sau
- Thanh điều hướng dưới cùng gồm ba tab: Thư viện, Album, Thông tin nhóm

## Công nghệ 

- Flutter, ngôn ngữ Dart
- `epubx`: đọc file EPUB
- `html`: chuyển nội dung HTML của chương thành các đoạn văn
- `file_picker` (bản 8.x): chọn file từ máy
- `path_provider`: lấy thư mục lưu file của ứng dụng
- `shared_preferences`: lưu dữ liệu dạng JSON (không dùng cơ sở dữ liệu)
- `intl`: định dạng ngày
- `audioplayers`: phát âm thanh

## Cấu trúc thư mục

```
lib/
  main.dart
  models/      storable, item, book_item, album
  services/    json_storage, storage_service, album_service, epub_service
  screens/     home_screen, library_screen, reader_screen, album_screen, about_screen
  widgets/     book_tile, album_tile, group_title, language_switch, add_books_dialog
  utils/       app_strings, date_helper, sound_helper
assets/
  fonts/       Tinos
  images/      ảnh bìa mặc định
  sounds/      âm thanh chuyển chương
  icon/        Icon cho ứng dụng
docs/          bảng kiểm thử
```

Luồng dữ liệu: màn hình (screens) gọi lớp dịch vụ (services), dịch vụ đọc và ghi dữ liệu qua `json_storage` rồi chuyển thành các đối tượng trong `models`. File sách được chép vào thư mục riêng của ứng dụng, danh sách sách và album được lưu dạng JSON.

## Chạy từ mã nguồn

Yêu cầu: đã cài Flutter và Android SDK, có máy ảo Android hoặc điện thoại Android bật USB debugging.

```
flutter pub get
flutter run
```

## Kiểm thử

Bảng kiểm thử chức năng nằm trong thư mục `docs`:
- `docs/test-reader.md`: đọc EPUB
- `docs/test_album.md`: album

