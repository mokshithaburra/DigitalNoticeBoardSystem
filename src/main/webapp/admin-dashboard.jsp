<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalnoticeboard.model.Notice" %>
<%
    if (session == null || session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Notice> activeNotices = (List<Notice>) request.getAttribute("activeNotices");
    List<Notice> expiredNotices = (List<Notice>) request.getAttribute("expiredNotices");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #f8fafc; }
        .container { max-width: 1100px; margin: 24px auto; padding: 0 16px; }
        .topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
        .btn { border: none; border-radius: 8px; padding: 10px 14px; text-decoration: none; cursor: pointer; }
        .btn-primary { background: #2563eb; color: white; }
        .btn-danger { background: #dc2626; color: white; }
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        th, td { padding: 10px; border-bottom: 1px solid #e5e7eb; text-align: left; vertical-align: top; }
        th { background: #eff6ff; }
        .section { margin-top: 24px; }
        .faded { opacity: 0.65; }
        .actions { display: flex; gap: 8px; }
        form { margin: 0; }
    </style>
</head>
<body>
<div class="container">
    <div class="topbar">
        <h2>Admin Dashboard</h2>
        <div>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/notice/create">Create Notice</a>
            <a class="btn" href="<%= request.getContextPath() %>/login?force=true">Switch User</a>
        </div>
    </div>

    <div class="section">
        <h3>Active Notices</h3>
        <table>
            <thead>
            <tr>
                <th>Title</th>
                <th>Category</th>
                <th>Priority</th>
                <th>Created</th>
                <th>Expiry</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% if (activeNotices != null && !activeNotices.isEmpty()) { %>
                <% for (Notice notice : activeNotices) { %>
                    <tr>
                        <td><strong><%= notice.getTitle() %></strong><br><small><%= notice.getDescription() %></small></td>
                        <td><%= notice.getCategory() %></td>
                        <td><%= notice.getPriority() %></td>
                        <td><%= notice.getCreatedAt() %></td>
                        <td><%= notice.getExpiryDate() == null ? "No Expiry" : notice.getExpiryDate() %></td>
                        <td>
                            <div class="actions">
                                <a class="btn" href="<%= request.getContextPath() %>/notice/edit?id=<%= notice.getNoticeId() %>">Edit</a>
                                <form method="post" action="<%= request.getContextPath() %>/notice/delete">
                                    <input type="hidden" name="id" value="<%= notice.getNoticeId() %>">
                                    <button class="btn btn-danger" type="submit" onclick="return confirm('Delete this notice?')">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                <% } %>
            <% } else { %>
                <tr><td colspan="6">No active notices available.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <div class="section faded">
        <h3>Expired Notices</h3>
        <table>
            <thead>
            <tr>
                <th>Title</th>
                <th>Category</th>
                <th>Priority</th>
                <th>Created</th>
                <th>Expired On</th>
            </tr>
            </thead>
            <tbody>
            <% if (expiredNotices != null && !expiredNotices.isEmpty()) { %>
                <% for (Notice notice : expiredNotices) { %>
                    <tr>
                        <td><strong><%= notice.getTitle() %></strong><br><small><%= notice.getDescription() %></small></td>
                        <td><%= notice.getCategory() %></td>
                        <td><%= notice.getPriority() %></td>
                        <td><%= notice.getCreatedAt() %></td>
                        <td><%= notice.getExpiryDate() %></td>
                    </tr>
                <% } %>
            <% } else { %>
                <tr><td colspan="5">No expired notices.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
