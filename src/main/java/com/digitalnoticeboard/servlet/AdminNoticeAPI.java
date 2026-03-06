package com.digitalnoticeboard.servlet;

import com.digitalnoticeboard.dao.NoticeDAO;
import com.digitalnoticeboard.model.Notice;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;

public class AdminNoticeAPI extends HttpServlet {
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            writeUnauthorized(response);
            return;
        }

        List<Notice> activeNotices = noticeDAO.getActiveNoticesForAdmin();
        List<Notice> expiredNotices = noticeDAO.getExpiredNotices();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"activeNotices\":" + toJsonArray(activeNotices) + ",\"expiredNotices\":" + toJsonArray(expiredNotices) + "}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            writeUnauthorized(response);
            return;
        }

        String action = valueOrEmpty(request.getParameter("action")).toLowerCase();
        if (action.isEmpty()) {
            action = "create";
        }

        switch (action) {
            case "create":
                handleCreate(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = normalizeCategory(request.getParameter("category"));
        String priorityValue = request.getParameter("priority");
        String expiryDateValue = request.getParameter("expiryDate");

        String error = validateNoticeInput(title, description, category, priorityValue, expiryDateValue);
        if (error != null) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, error);
            return;
        }

        int priority = toPriority(priorityValue);
        Date expiryDate = Date.valueOf(LocalDate.parse(expiryDateValue));

        HttpSession session = request.getSession(false);
        Integer createdBy = session == null ? null : (Integer) session.getAttribute("userId");
        if (createdBy == null) {
            writeUnauthorized(response);
            return;
        }

        Notice notice = new Notice();
        notice.setTitle(title.trim());
        notice.setDescription(description.trim());
        notice.setCategory(category);
        notice.setPriority(priority);
        notice.setExpiryDate(expiryDate);
        notice.setCreatedBy(createdBy);

        boolean success = noticeDAO.createNotice(notice);
        if (!success) {
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create notice");
            return;
        }

        writeSuccess(response, "Notice created");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String noticeIdValue = request.getParameter("noticeId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = normalizeCategory(request.getParameter("category"));
        String priorityValue = request.getParameter("priority");
        String expiryDateValue = request.getParameter("expiryDate");

        int noticeId;
        try {
            noticeId = Integer.parseInt(noticeIdValue);
        } catch (Exception exception) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid notice id");
            return;
        }

        String error = validateNoticeInput(title, description, category, priorityValue, expiryDateValue);
        if (error != null) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, error);
            return;
        }

        int priority = toPriority(priorityValue);
        Date expiryDate = Date.valueOf(LocalDate.parse(expiryDateValue));

        Notice notice = new Notice();
        notice.setNoticeId(noticeId);
        notice.setTitle(title.trim());
        notice.setDescription(description.trim());
        notice.setCategory(category);
        notice.setPriority(priority);
        notice.setExpiryDate(expiryDate);

        boolean success = noticeDAO.updateNotice(notice);
        if (!success) {
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update notice");
            return;
        }

        writeSuccess(response, "Notice updated");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String noticeIdValue = request.getParameter("noticeId");
        int noticeId;

        try {
            noticeId = Integer.parseInt(noticeIdValue);
        } catch (Exception exception) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid notice id");
            return;
        }

        boolean success = noticeDAO.deleteNotice(noticeId);
        if (!success) {
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to delete notice");
            return;
        }

        writeSuccess(response, "Notice deleted");
    }

    private int toPriority(String priorityValue) {
        String normalized = valueOrEmpty(priorityValue).trim().toLowerCase();
        switch (normalized) {
            case "high":
            case "1":
                return 1;
            case "medium":
            case "2":
                return 2;
            case "low":
            case "3":
                return 3;
            default:
                return -1;
        }
    }

    private String validateNoticeInput(String title, String description, String category, String priorityValue, String expiryDateValue) {
        if (isBlank(title) || isBlank(description)) {
            return "Title and description are required";
        }

        if (isBlank(category)) {
            return "Category cannot be empty";
        }

        int priority = toPriority(priorityValue);
        if (priority < 1 || priority > 3) {
            return "Priority must be high, medium, low or 1,2,3";
        }

        if (isBlank(expiryDateValue)) {
            return "Expiry date is required";
        }

        try {
            LocalDate expiryDate = LocalDate.parse(expiryDateValue);
            if (!expiryDate.isAfter(LocalDate.now())) {
                return "Expiry date must be a future date";
            }
        } catch (Exception exception) {
            return "Invalid expiry date";
        }

        return null;
    }

    private String normalizeCategory(String categoryValue) {
        String category = valueOrEmpty(categoryValue).trim();
        if (category.isEmpty()) {
            return category;
        }
        return category.substring(0, 1).toUpperCase() + category.substring(1).toLowerCase();
    }

    private void writeSuccess(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}");
    }

    private void writeError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(message) + "\"}");
    }

    private void writeUnauthorized(HttpServletResponse response) throws IOException {
        writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
    }

    private String toJsonArray(List<Notice> notices) {
        StringBuilder builder = new StringBuilder();
        builder.append('[');
        for (int index = 0; index < notices.size(); index++) {
            Notice notice = notices.get(index);
            if (index > 0) {
                builder.append(',');
            }
            builder.append('{')
                    .append("\"noticeId\":").append(notice.getNoticeId()).append(',')
                    .append("\"title\":\"").append(escapeJson(notice.getTitle())).append("\",")
                    .append("\"description\":\"").append(escapeJson(notice.getDescription())).append("\",")
                    .append("\"category\":\"").append(escapeJson(notice.getCategory())).append("\",")
                    .append("\"priority\":").append(notice.getPriority()).append(',')
                    .append("\"createdAt\":\"").append(notice.getCreatedAt() == null ? "" : notice.getCreatedAt().toString()).append("\",")
                    .append("\"createdAtEpoch\":").append(toEpochMillis(notice.getCreatedAt())).append(',')
                    .append("\"expiryDate\":\"").append(notice.getExpiryDate() == null ? "" : notice.getExpiryDate().toString()).append("\"")
                    .append('}');
        }
        builder.append(']');
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

    private String valueOrEmpty(String value) {
        return value == null ? "" : value;
    }

    private long toEpochMillis(Timestamp timestamp) {
        return timestamp == null ? 0L : timestamp.getTime();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && "admin".equals(session.getAttribute("role"));
    }
}
