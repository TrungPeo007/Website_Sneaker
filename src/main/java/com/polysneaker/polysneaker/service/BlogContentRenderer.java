package com.polysneaker.polysneaker.service;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Component;

/**
 * Đổi nội dung chữ thường admin gõ thành HTML an toàn (mọi ký tự HTML đều bị escape trước).
 *
 *   ## Tiêu đề lớn        ### Tiêu đề nhỏ
 *   - gạch đầu dòng       > trích dẫn
 *   **in đậm**            [chữ link](https://...)
 *   ![chú thích ảnh](ten-file.jpg)   (một dòng riêng)
 *   Dòng trống = đoạn mới.
 */
@Component
public class BlogContentRenderer {

    private static final Pattern IMAGE = Pattern.compile("^!\\[([^\\]]*)\\]\\(([^)\\s]+)\\)$");
    private static final Pattern BOLD = Pattern.compile("\\*\\*(.+?)\\*\\*");
    private static final Pattern LINK = Pattern.compile("\\[([^\\]]+)\\]\\((https?://[^\\s)]+)\\)");

    private final BlogImageResolver images;

    public BlogContentRenderer(BlogImageResolver images) {
        this.images = images;
    }

    public String toHtml(String text, String ctx) {
        if (text == null || text.isBlank()) return "";

        StringBuilder out = new StringBuilder();
        StringBuilder para = new StringBuilder();
        boolean inList = false;

        for (String raw : text.replace("\r\n", "\n").replace('\r', '\n').split("\n", -1)) {
            String line = raw.strip();
            boolean bullet = line.startsWith("- ");

            if (inList && !bullet) {
                out.append("</ul>\n");
                inList = false;
            }
            if (line.isEmpty()) {
                flush(out, para);
                continue;
            }

            Matcher img = IMAGE.matcher(line);
            if (line.startsWith("### ")) {
                flush(out, para);
                out.append("<h3>").append(inline(line.substring(4))).append("</h3>\n");
            } else if (line.startsWith("## ")) {
                flush(out, para);
                out.append("<h2>").append(inline(line.substring(3))).append("</h2>\n");
            } else if (bullet) {
                flush(out, para);
                if (!inList) {
                    out.append("<ul>\n");
                    inList = true;
                }
                out.append("<li>").append(inline(line.substring(2))).append("</li>\n");
            } else if (line.startsWith("> ")) {
                flush(out, para);
                out.append("<blockquote>").append(inline(line.substring(2))).append("</blockquote>\n");
            } else if (img.matches()) {
                flush(out, para);
                String alt = escape(img.group(1));
                String src = escape(images.resolve(img.group(2), ctx));
                out.append("<figure><img src=\"").append(src).append("\" alt=\"").append(alt).append("\" loading=\"lazy\">");
                if (!alt.isEmpty()) out.append("<figcaption>").append(alt).append("</figcaption>");
                out.append("</figure>\n");
            } else {
                if (para.length() > 0) para.append("<br>");
                para.append(inline(line));
            }
        }
        flush(out, para);
        if (inList) out.append("</ul>\n");
        return out.toString();
    }

    private static void flush(StringBuilder out, StringBuilder para) {
        if (para.length() > 0) {
            out.append("<p>").append(para).append("</p>\n");
            para.setLength(0);
        }
    }

    private static String inline(String s) {
        String e = escape(s);
        e = LINK.matcher(e).replaceAll("<a href=\"$2\" target=\"_blank\" rel=\"noopener\">$1</a>");
        e = BOLD.matcher(e).replaceAll("<strong>$1</strong>");
        return e;
    }

    private static String escape(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}