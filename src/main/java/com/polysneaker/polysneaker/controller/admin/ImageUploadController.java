package com.polysneaker.polysneaker.controller.admin;

import com.polysneaker.polysneaker.dto.LoginUser;
import jakarta.servlet.http.HttpSession;
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
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * Nhận ảnh sản phẩm từ trang admin, lưu vào thư mục ảnh tĩnh
 * và trả về TÊN FILE (không kèm đường dẫn) để lưu vào Products.MainImageUrl / ProductImages.ImageUrl.
 *
 * Nhận mọi loại ảnh: nhận dạng qua nội dung thật của file (JPG, PNG, GIF, WEBP, BMP, TIFF, ICO,
 * AVIF, HEIC/HEIF, JPEG XL, JPEG 2000, SVG). Các đuôi ảnh hiếm khác nhận theo đuôi file.
 * Tên file lưu trên máy chủ luôn do server tự đặt.
 *
 * Thư mục lưu cấu hình bằng app.upload-dir trong application.properties
 * (mặc định: src/main/webapp/static/assets/images, tính từ thư mục chạy app).
 */
@RestController
public class ImageUploadController {

    private static final long MAX_SIZE = 5L * 1024 * 1024; // 5MB
    private static final int HEAD_BYTES = 2048;             // đủ để nhận dạng định dạng, kể cả SVG

    /** Đuôi ảnh hiếm, không nhận dạng được qua nội dung nên nhận theo đuôi file. */
    private static final Set<String> OTHER_IMAGE_EXT = Set.of(
            "j2k", "jpx", "psd", "tga", "dds", "hdr", "exr", "pcx",
            "pnm", "pbm", "pgm", "ppm", "wbmp", "xbm");

    /** Thuộc tính sự kiện kiểu onclick=, onload= trong SVG. */
    private static final Pattern SVG_EVENT_ATTR = Pattern.compile("[\\s\"'/]on[a-z]+\\s*=");

    private final Path root;

    public ImageUploadController(
            @Value("${app.upload-dir:src/main/webapp/static/assets/images}") String uploadDir) {
        this.root = Paths.get(uploadDir).toAbsolutePath().normalize();
    }

    @PostMapping("/admin/upload/image")
    public ResponseEntity<Map<String, String>> upload(@RequestParam("file") MultipartFile file,
                                                      HttpSession session) {
        // Chỉ admin đang đăng nhập mới được tải ảnh lên
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser user)) {
            return error(HttpStatus.UNAUTHORIZED, "Bạn chưa đăng nhập, hãy đăng nhập lại");
        }
        if (!"ADMIN".equals(user.getRole())) {                       // nếu LoginUser là record: user.role()
            return error(HttpStatus.FORBIDDEN, "Bạn không có quyền tải ảnh lên");
        }

        if (file == null || file.isEmpty()) {
            return error(HttpStatus.BAD_REQUEST, "Chưa chọn file");
        }
        if (file.getSize() > MAX_SIZE) {
            return error(HttpStatus.PAYLOAD_TOO_LARGE, "Ảnh tối đa 5MB");
        }

        // Kiểm tra nội dung thật của file (không tin content-type do client gửi)
        byte[] head;
        try (InputStream in = file.getInputStream()) {
            head = in.readNBytes(HEAD_BYTES);
        } catch (IOException e) {
            return error(HttpStatus.BAD_REQUEST, "Không đọc được file");
        }

        String ext = detectExtension(head);
        if (ext == null) {
            ext = otherImageExtension(file.getOriginalFilename());   // đuôi ảnh hiếm: nhận theo đuôi file
        }
        if (ext == null) {
            return error(HttpStatus.BAD_REQUEST, "File này không phải file ảnh");
        }

        // SVG có thể chứa mã chạy nên kiểm tra thêm
        if ("svg".equals(ext)) {
            try {
                String svg = new String(file.getBytes(), StandardCharsets.UTF_8).toLowerCase(Locale.ROOT);
                if (svg.contains("<script") || svg.contains("javascript:") || svg.contains("<foreignobject")
                        || SVG_EVENT_ATTR.matcher(svg).find()) {
                    return error(HttpStatus.BAD_REQUEST, "File SVG chứa mã script nên không được chấp nhận");
                }
            } catch (IOException e) {
                return error(HttpStatus.BAD_REQUEST, "Không đọc được file");
            }
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

    /** Nhận dạng định dạng ảnh qua magic bytes. Trả null nếu không nhận ra. */
    private static String detectExtension(byte[] h) {
        if (startsWith(h, 0xFF, 0xD8, 0xFF)) return "jpg";                       // JPEG / JFIF
        if (startsWith(h, 0x89, 0x50, 0x4E, 0x47)) return "png";                 // PNG / APNG
        if (asciiAt(h, 0, "GIF8")) return "gif";
        if (asciiAt(h, 0, "RIFF") && asciiAt(h, 8, "WEBP")) return "webp";
        if (isBmp(h)) return "bmp";
        if (startsWith(h, 0x49, 0x49, 0x2A, 0x00) || startsWith(h, 0x4D, 0x4D, 0x00, 0x2A)) return "tif";

        // ICO / CUR: 00 00 01|02 00 + số lượng ảnh khác 0
        if (h.length >= 6 && (startsWith(h, 0, 0, 1, 0) || startsWith(h, 0, 0, 2, 0)) && ((h[4] | h[5]) != 0)) {
            return h[2] == 1 ? "ico" : "cur";
        }

        // AVIF / HEIC / HEIF: khối "ftyp" ở byte 4..7, tên loại ở byte 8..11
        if (asciiAt(h, 4, "ftyp") && h.length >= 12) {
            String brand = new String(h, 8, 4, StandardCharsets.US_ASCII);
            switch (brand) {
                case "avif", "avis" -> { return "avif"; }
                case "heic", "heix", "hevc", "hevx", "heim", "heis", "hevm", "hevs" -> { return "heic"; }
                case "mif1", "msf1" -> { return "heif"; }
                default -> { /* ftyp của video (mp4...) thì bỏ qua */ }
            }
        }

        // JPEG XL
        if (startsWith(h, 0xFF, 0x0A)
                || startsWith(h, 0x00, 0x00, 0x00, 0x0C, 0x4A, 0x58, 0x4C, 0x20, 0x0D, 0x0A, 0x87, 0x0A)) {
            return "jxl";
        }
        // JPEG 2000
        if (startsWith(h, 0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20, 0x0D, 0x0A, 0x87, 0x0A)) {
            return "jp2";
        }
        if (looksLikeSvg(h)) return "svg";
        return null;
    }

    /** BMP: "BM" và kích thước phần đầu DIB hợp lệ (tránh nhầm với file chữ bắt đầu bằng BM). */
    private static boolean isBmp(byte[] h) {
        if (h.length < 18 || !asciiAt(h, 0, "BM")) return false;
        int dib = (h[14] & 0xFF) | ((h[15] & 0xFF) << 8) | ((h[16] & 0xFF) << 16) | ((h[17] & 0xFF) << 24);
        return dib == 12 || dib == 40 || dib == 52 || dib == 56 || dib == 64 || dib == 108 || dib == 124;
    }

    private static boolean looksLikeSvg(byte[] h) {
        String head = new String(h, StandardCharsets.UTF_8).toLowerCase(Locale.ROOT);
        if (head.startsWith("\uFEFF")) head = head.substring(1);
        head = head.stripLeading();
        return head.contains("<svg")
                && (head.startsWith("<svg") || head.startsWith("<?xml") || head.startsWith("<!doctype") || head.startsWith("<!--"));
    }

    private static boolean startsWith(byte[] h, int... sig) {
        if (h.length < sig.length) return false;
        for (int i = 0; i < sig.length; i++) {
            if ((h[i] & 0xFF) != sig[i]) return false;
        }
        return true;
    }

    private static boolean asciiAt(byte[] h, int off, String s) {
        if (h.length < off + s.length()) return false;
        for (int i = 0; i < s.length(); i++) {
            if (h[off + i] != s.charAt(i)) return false;
        }
        return true;
    }

    /** Đuôi file (viết thường) nếu nằm trong danh sách đuôi ảnh hiếm, ngược lại trả null. */
    private static String otherImageExtension(String originalName) {
        if (originalName == null) return null;
        int dot = originalName.lastIndexOf('.');
        if (dot < 0 || dot == originalName.length() - 1) return null;
        String e = originalName.substring(dot + 1).toLowerCase(Locale.ROOT);
        return OTHER_IMAGE_EXT.contains(e) ? e : null;
    }

    private static ResponseEntity<Map<String, String>> error(HttpStatus status, String message) {
        return ResponseEntity.status(status).body(Map.of("error", message));
    }
}