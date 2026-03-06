package com.digitalnoticeboard.servlet;

import com.digitalnoticeboard.dao.NoticeDAO;
import com.digitalnoticeboard.model.Notice;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.sql.Timestamp;

public class NoticeAPI extends HttpServlet {
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        List<Notice> notices = noticeDAO.getActiveNoticesForStudent();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(toJson(notices));
    }

    private String toJson(List<Notice> notices) {
        StringBuilder builder = new StringBuilder();
        builder.append("{\"notices\":[");

        for (int index = 0; index < notices.size(); index++) {
            Notice notice = notices.get(index);
            if (index > 0) {
                builder.append(',');
            }

            long publishToDisplaySeconds = 0;
            if (notice.getCreatedAt() != null) {
                publishToDisplaySeconds = Duration.between(notice.getCreatedAt().toInstant(), Instant.now()).getSeconds();
                if (publishToDisplaySeconds < 0) {
                    publishToDisplaySeconds = 0;
                }
            }

            builder.append('{')
                    .append("\"noticeId\":").append(notice.getNoticeId()).append(',')
                    .append("\"title\":\"").append(escapeJson(notice.getTitle())).append("\",")
                    .append("\"description\":\"").append(escapeJson(notice.getDescription())).append("\",")
                    .append("\"category\":\"").append(escapeJson(notice.getCategory())).append("\",")
                    .append("\"priority\":").append(notice.getPriority()).append(',')
                    .append("\"createdAt\":\"").append(notice.getCreatedAt() == null ? "" : notice.getCreatedAt().toString()).append("\",")
                    .append("\"createdAtEpoch\":").append(toEpochMillis(notice.getCreatedAt())).append(',')
                    .append("\"expiryDate\":\"").append(notice.getExpiryDate() == null ? "" : notice.getExpiryDate().toString()).append("\",")
                    .append("\"publishToDisplaySeconds\":").append(publishToDisplaySeconds)
                    .append('}');
        }

        builder.append("]}");
        return builder.toString();
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private long toEpochMillis(Timestamp timestamp) {
        return timestamp == null ? 0L : timestamp.getTime();
    }
}
