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
import java.time.LocalDate;

public class EditNoticeServlet extends HttpServlet {
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idText = request.getParameter("id");
        int noticeId;
        try {
            noticeId = Integer.parseInt(idText);
        } catch (Exception exception) {
            response.sendRedirect(request.getContextPath() + "/admin/notices");
            return;
        }

        Notice notice = noticeDAO.getNoticeById(noticeId);
        if (notice == null) {
            response.sendRedirect(request.getContextPath() + "/admin/notices");
            return;
        }

        request.setAttribute("notice", notice);
        request.setAttribute("mode", "edit");
        request.getRequestDispatcher("/createNotice.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String noticeIdText = request.getParameter("noticeId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String priorityText = request.getParameter("priority");
        String expiryDateText = request.getParameter("expiryDate");

        int noticeId;
        try {
            noticeId = Integer.parseInt(noticeIdText);
        } catch (Exception exception) {
            response.sendRedirect(request.getContextPath() + "/admin/notices");
            return;
        }

        String validationError = validateInput(title, description, category, priorityText, expiryDateText);
        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.setAttribute("mode", "edit");
            Notice notice = noticeDAO.getNoticeById(noticeId);
            request.setAttribute("notice", notice);
            request.getRequestDispatcher("/createNotice.jsp").forward(request, response);
            return;
        }

        Notice notice = new Notice();
        notice.setNoticeId(noticeId);
        notice.setTitle(title.trim());
        notice.setDescription(description.trim());
        notice.setCategory(category.trim());
        notice.setPriority(Integer.parseInt(priorityText));

        if (expiryDateText != null && !expiryDateText.trim().isEmpty()) {
            notice.setExpiryDate(Date.valueOf(LocalDate.parse(expiryDateText)));
        }

        if (noticeDAO.updateNotice(notice)) {
            response.sendRedirect(request.getContextPath() + "/admin/notices");
            return;
        }

        request.setAttribute("error", "Unable to update notice. Please try again.");
        request.setAttribute("mode", "edit");
        request.setAttribute("notice", noticeDAO.getNoticeById(noticeId));
        request.getRequestDispatcher("/createNotice.jsp").forward(request, response);
    }

    private String validateInput(String title, String description, String category, String priorityText, String expiryDateText) {
        if (isBlank(title) || isBlank(description)) {
            return "Title and description are required.";
        }

        if (isBlank(category)) {
            return "Category cannot be empty.";
        }

        int priority;
        try {
            priority = Integer.parseInt(priorityText);
        } catch (Exception exception) {
            return "Priority must be 1, 2, or 3.";
        }

        if (priority < 1 || priority > 3) {
            return "Priority must be 1, 2, or 3.";
        }

        if (expiryDateText != null && !expiryDateText.trim().isEmpty()) {
            LocalDate expiryDate;
            try {
                expiryDate = LocalDate.parse(expiryDateText);
            } catch (Exception exception) {
                return "Expiry date format is invalid.";
            }

            if (!expiryDate.isAfter(LocalDate.now())) {
                return "Expiry date must be a future date.";
            }
        }

        return null;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && "admin".equals(session.getAttribute("role"));
    }
}
