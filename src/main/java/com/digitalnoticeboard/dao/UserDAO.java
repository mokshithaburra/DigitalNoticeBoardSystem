package com.digitalnoticeboard.dao;

import com.digitalnoticeboard.config.DBConnection;
import com.digitalnoticeboard.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User authenticateUser(String username, String password, String role) {
        String sql = "SELECT user_id, username, password, role, email FROM users WHERE username = ? AND password = ? AND role = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, username);
            preparedStatement.setString(2, password);
            preparedStatement.setString(3, role);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    User user = new User();
                    user.setUserId(resultSet.getInt("user_id"));
                    user.setUsername(resultSet.getString("username"));
                    user.setPassword(resultSet.getString("password"));
                    user.setRole(resultSet.getString("role"));
                    user.setEmail(resultSet.getString("email"));
                    return user;
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return null;
    }
}
