package com.polysneaker.polysneaker.service;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

/** Đổi tiêu đề tiếng Việt thành slug: "Giày Nike mới" -> "giay-nike-moi". */
public final class SlugUtil {

    private static final Pattern MARKS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    private SlugUtil() { }

    public static String slugify(String text) {
        if (text == null) return "";
        String s = text.replace('đ', 'd').replace('Đ', 'D');
        s = Normalizer.normalize(s, Normalizer.Form.NFD);
        s = MARKS.matcher(s).replaceAll("");
        s = s.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-").replaceAll("^-+|-+$", "");
        if (s.length() > 200) {
            s = s.substring(0, 200).replaceAll("-+$", "");
        }
        return s;
    }
}