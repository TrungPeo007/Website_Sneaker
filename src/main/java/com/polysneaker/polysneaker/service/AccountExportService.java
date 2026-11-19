package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.dto.RegisteredInfo;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

@Service
public class AccountExportService {

    public byte[] buildXlsx(RegisteredInfo info) throws IOException {
        try (XSSFWorkbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Tài khoản");

            Font bold = wb.createFont();
            bold.setBold(true);
            Font title = wb.createFont();
            title.setBold(true);
            title.setFontHeightInPoints((short) 14);

            CellStyle titleStyle = wb.createCellStyle();
            titleStyle.setFont(title);
            CellStyle labelStyle = wb.createCellStyle();
            labelStyle.setFont(bold);

            int r = 0;
            r = put(sheet, r, "THÔNG TIN TÀI KHOẢN POLYSNEAKER", null, titleStyle);
            r++; // dòng trống
            r = put(sheet, r, "Tên đăng nhập", info.getUsername(), labelStyle);
            r = put(sheet, r, "Email", info.getEmail(), labelStyle);
            r = put(sheet, r, "Mật khẩu", info.getPassword(), labelStyle);
            r = put(sheet, r, "Thời gian đăng ký",
                    info.getRegisteredAt().format(DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy")), labelStyle);
            r++;
            put(sheet, r, "Lưu ý: file này chứa mật khẩu của bạn, hãy cất giữ cẩn thận và không chia sẻ cho người khác.",
                    null, null);

            sheet.setColumnWidth(0, 26 * 256);
            sheet.setColumnWidth(1, 48 * 256);

            wb.write(out);
            return out.toByteArray();
        }
    }

    /** Ghi 1 dòng (nhãn ở cột A, giá trị ở cột B), trả về chỉ số dòng kế tiếp. */
    private int put(Sheet sheet, int rowIdx, String label, String value, CellStyle labelStyle) {
        Row row = sheet.createRow(rowIdx);
        Cell a = row.createCell(0);
        a.setCellValue(label);
        if (labelStyle != null) a.setCellStyle(labelStyle);
        if (value != null) {
            row.createCell(1).setCellValue(value);
        }
        return rowIdx + 1;
    }
}