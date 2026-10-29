package com.polysneaker.polysneaker.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.UUID;

/**
 * Nhận ảnh sản phẩm từ trang admin, lưu vào thư mục ảnh tĩnh
 * và trả về TÊN FILE (không kèm đường dẫn) để lưu vào Products.MainImageUrl.
 *
 * Thư mục lưu cấu hình bằng app.upload-dir trong application.properties
 * (mặc định: src/main/webapp/static/assets/images, tính từ thư mục chạy app).
 */
@RestController
public class ImageUploadController {

    private static final long MAX_SIZE = 5L * 1024 * 1024; // 5MB

    private final Path root;

    public ImageUploadController(
            @Value("${app.upload-dir:src/main/webapp/static/assets/images}") String uploadDir) {
        this.root = Paths.get(uploadDir).toAbsolutePath().normalize();
    }

    @PostMapping("/admin/upload/image")
    public ResponseEntity<Map<String, String>> upload(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return error(HttpStatus.BAD_REQUEST, "Chưa chọn file");
        }
        if (file.getSize() > MAX_SIZE) {
            return error(HttpStatus.PAYLOAD_TOO_LARGE, "Ảnh tối đa 5MB");
        }

        // Kiểm tra nội dung thật của file (không tin tên file / content-type do client gửi)
        String ext;
        try (InputStream in = file.getInputStream()) {
            ext = detectExtension(in.readNBytes(12));
        } catch (IOException e) {
            return error(HttpStatus.BAD_REQUEST, "Không đọc được file");
        }
        if (ext == null) {
            return error(HttpStatus.BAD_REQUEST, "Chỉ chấp nhận ảnh JPG, PNG, WEBP hoặc GIF");
        }

        // Tên file do server tự đặt, tránh trùng tên và tránh path traversal
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;

        try {
            Files.createDirectories(root);
            Path target = root.resolve(fileName).normalize();
            if (!target.startsWith(root)) {
                return error(HttpStatus.BAD_REQUEST, "Tên file không hợp lệ");
            }
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, "Không lưu được file lên máy chủ");
        }

        return ResponseEntity.ok(Map.of("fileName", fileName));
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, String>> tooLarge() {
        return error(HttpStatus.PAYLOAD_TOO_LARGE, "Ảnh tối đa 5MB");
    }

    /** Nhận dạng định dạng ảnh qua magic bytes. Trả null nếu không phải ảnh được hỗ trợ. */
    private static String detectExtension(byte[] h) {
        if (h.length >= 3 && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8 && (h[2] & 0xFF) == 0xFF) {
            return "jpg";
        }
        if (h.length >= 4 && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G') {
            return "png";
        }
        if (h.length >= 4 && h[0] == 'G' && h[1] == 'I' && h[2] == 'F' && h[3] == '8') {
            return "gif";
        }
        if (h.length >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
                && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') {
            return "webp";
        }
        return null;
    }

    private static ResponseEntity<Map<String, String>> error(HttpStatus status, String message) {
        return ResponseEntity.status(status).body(Map.of("error", message));
    }
}