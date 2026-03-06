<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Digital Notice Board</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f7ff; margin: 0; }
        .container { min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .card { width: 100%; max-width: 420px; background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        h1 { margin-top: 0; font-size: 24px; color: #1f2937; }
        .field { margin-bottom: 14px; }
        label { display: block; margin-bottom: 6px; color: #374151; }
        input, select { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; }
        button { width: 100%; padding: 12px; border: none; border-radius: 8px; background: #2563eb; color: #fff; font-weight: 600; cursor: pointer; }
        .error { background: #fee2e2; color: #991b1b; padding: 10px; border-radius: 8px; margin-bottom: 14px; }
    </style>
</head>
<body>
<div class="container">
    <div class="card">
        <h1>Digital Notice Board Login</h1>
        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="error"><%= error %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login">
            <div class="field">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="field">
                <label for="role">Role</label>
                <select id="role" name="role" required>
                    <option value="">Select role</option>
                    <option value="admin">Admin</option>
                    <option value="student">Student</option>
                </select>
            </div>
            <button type="submit">Login</button>
        </form>
    </div>
</div>
</body>
</html>
