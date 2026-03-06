<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.digitalnoticeboard.model.Notice" %>
<%
    if (session == null || session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Notice notice = (Notice) request.getAttribute("notice");
    String mode = (String) request.getAttribute("mode");
    boolean isEdit = "edit".equals(mode);
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit Notice" : "Create Notice" %></title>
    <style>
        body { font-family: Arial, sans-serif; background: #f7fafc; margin: 0; }
        .wrapper { max-width: 760px; margin: 24px auto; background: #fff; border-radius: 12px; box-shadow: 0 6px 16px rgba(0,0,0,0.08); padding: 24px; }
        h2 { margin-top: 0; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .field { margin-bottom: 12px; }
        label { display: block; margin-bottom: 6px; }
        input, textarea, select { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; box-sizing: border-box; }
        textarea { min-height: 120px; resize: vertical; }
        .actions { display: flex; gap: 10px; margin-top: 16px; }
        .btn { border: none; border-radius: 8px; padding: 10px 16px; cursor: pointer; text-decoration: none; display: inline-block; }
        .primary { background: #1d4ed8; color: #fff; }
        .secondary { background: #e5e7eb; color: #111827; }
        .error { background: #fee2e2; color: #991b1b; padding: 10px; border-radius: 8px; margin-bottom: 12px; }
    </style>
</head>
<body>
<div class="wrapper">
    <h2><%= isEdit ? "Edit Notice" : "Create New Notice" %></h2>
    <% if (error != null) { %><div class="error"><%= error %></div><% } %>

    <form method="post" action="<%= request.getContextPath() + (isEdit ? "/notice/edit" : "/notice/create") %>">
        <% if (isEdit && notice != null) { %>
            <input type="hidden" name="noticeId" value="<%= notice.getNoticeId() %>">
        <% } %>

        <div class="field">
            <label for="title">Title</label>
            <input type="text" id="title" name="title" required value="<%= notice == null ? "" : notice.getTitle() %>">
        </div>

        <div class="field">
            <label for="description">Description</label>
            <textarea id="description" name="description" required><%= notice == null ? "" : notice.getDescription() %></textarea>
        </div>

        <div class="grid">
            <div class="field">
                <label for="category">Category</label>
                <select id="category" name="category" required>
                    <option value="">Select category</option>
                    <% String currentCategory = notice == null ? "" : notice.getCategory(); %>
                    <option value="Exam" <%= "Exam".equals(currentCategory) ? "selected" : "" %>>Exam</option>
                    <option value="Events" <%= "Events".equals(currentCategory) ? "selected" : "" %>>Events</option>
                    <option value="Circulars" <%= "Circulars".equals(currentCategory) ? "selected" : "" %>>Circulars</option>
                    <option value="Placement" <%= "Placement".equals(currentCategory) ? "selected" : "" %>>Placement</option>
                    <option value="General" <%= "General".equals(currentCategory) ? "selected" : "" %>>General</option>
                </select>
            </div>
            <div class="field">
                <label for="priority">Priority</label>
                <select id="priority" name="priority" required>
                    <% int currentPriority = notice == null ? 2 : notice.getPriority(); %>
                    <option value="1" <%= currentPriority == 1 ? "selected" : "" %>>1 - High</option>
                    <option value="2" <%= currentPriority == 2 ? "selected" : "" %>>2 - Medium</option>
                    <option value="3" <%= currentPriority == 3 ? "selected" : "" %>>3 - Low</option>
                </select>
            </div>
        </div>

        <div class="field">
            <label for="expiryDate">Expiry Date (optional)</label>
            <input type="date" id="expiryDate" name="expiryDate" value="<%= (notice != null && notice.getExpiryDate() != null) ? notice.getExpiryDate().toString() : "" %>">
        </div>

        <div class="actions">
            <button type="submit" class="btn primary"><%= isEdit ? "Update Notice" : "Create Notice" %></button>
            <a class="btn secondary" href="<%= request.getContextPath() %>/admin/notices">Back</a>
        </div>
    </form>
</div>
</body>
</html>
