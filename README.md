# Digital Notice Board System

A modern, responsive web-based notice board system for educational institutions, allowing administrators to create and manage notices while students can view them in an organized, prioritized manner.

## 📌 Project Status

✅ **Frontend Development Complete**
- Landing page with feature highlights
- Login page with role-based authentication (UI only)
- Admin dashboard with notice creation and management
- Student dashboard with filtering and search capabilities
- Responsive design for all screen sizes
- Consistent styling with priority-based color coding

✅ **Database Schema Complete**
- Oracle SQL database schema with 4 tables
- Sequences, indexes, and constraints
- Triggers for automation
- Views for common queries
- Stored procedures for CRUD operations
- Sample data for testing

❌ **Backend NOT Started Yet**
❌ **Authentication Logic NOT Implemented Yet**

## 🎯 Features

### For Students
- **View Notices**: Browse all active notices with clear visibility
- **Filter by Category**: Filter notices by Exam, Event, Emergency, General, Academic, or Placement
- **Priority-Based Display**: High-priority notices displayed first with color coding
- **Search Functionality**: Quick search across notice titles and descriptions
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices

### For Administrators
- **Create Notices**: Add new notices with title, description, category, priority, and expiry date
- **Manage Notices**: View all notices in a table format
- **Edit/Delete**: Actions to modify or remove notices (UI ready, backend pending)
- **Search & Filter**: Find specific notices quickly
- **Form Validation**: Client-side validation for required fields

## 🗂️ Project Structure

```
digital-notice-board/
│
├── index.html              # Landing page
│
├── auth/
│   └── login.html         # Login page (role-based)
│
├── admin/
│   └── admin-dashboard.html  # Admin dashboard
│
├── student/
│   └── student-dashboard.html  # Student dashboard
│
├── css/
│   └── style.css          # Global stylesheet
│
├── database/              # Database schema and scripts
│   ├── schema.sql        # Oracle SQL schema
│   ├── sample_data.sql   # Sample test data
│   ├── ER_DIAGRAM.md     # Entity-Relationship diagram
│   └── README.md         # Database documentation
│
└── assets/
    └── images/            # Image assets (empty for now)
```

## 🚀 Quick Start

### Viewing the Application

1. Clone the repository:
   ```bash
   git clone https://github.com/mokshithaburra/DigitalNoticeBoardSystem.git
   cd DigitalNoticeBoardSystem
   ```

2. Open `index.html` in your web browser, or use a local server:
   ```bash
   python3 -m http.server 8080
   ```
   Then navigate to `http://localhost:8080`

3. Navigate through the application:
   - Click "Get Started" on the landing page
   - Select a role (Admin/Student) and click Login (credentials not required yet)
   - Explore the respective dashboard

### Setting Up the Database

1. Install Oracle Database (11g or higher)

2. Connect to your database using SQL*Plus or Oracle SQL Developer

3. Run the schema creation script:
   ```sql
   @database/schema.sql
   ```

4. Load sample data (optional, for testing):
   ```sql
   @database/sample_data.sql
   ```

5. Verify installation:
   ```sql
   SELECT table_name FROM user_tables;
   ```

**Sample Credentials:**
- Admin: username=`admin`, password=`admin123`
- Student: username=`student`, password=`student123`

For detailed database documentation, see [database/README.md](database/README.md)

## 🎨 Design Features

### Color Scheme
- **Primary Color**: Indigo (#4F46E5)
- **Priority Colors**:
  - High Priority: Red (#EF4444)
  - Medium Priority: Orange (#F59E0B)
  - Low Priority: Green (#10B981)

### Typography
- Font Family: Poppins (Google Fonts)
- Clean, modern, and readable design

### Responsive Breakpoints
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

## 📝 Notice Categories

1. **Exam** - Examination-related announcements
2. **Event** - College events and activities
3. **Emergency** - Urgent notifications
4. **General** - General announcements
5. **Academic** - Academic-related information
6. **Placement** - Placement and career-related notices

## 🔐 User Roles

### Admin
- Create new notices
- Edit existing notices
- Delete notices
- Set priority and expiry dates
- Manage all notice categories

### Student
- View active notices
- Filter by category
- Search notices
- View notices sorted by priority

## 🛠️ Tech Stack

### Frontend (Current)
- HTML5
- CSS3
- Vanilla JavaScript
- Google Fonts (Poppins)

### Backend (Planned)
- Python
- Flask framework

### Database (Implemented)
- Oracle SQL
- Complete schema with 4 tables
- Stored procedures and functions
- Triggers for automation
- Views for common queries
- See [database/README.md](database/README.md) for details

### Future Enhancements
- Email notifications (SMTP)
- User authentication
- Role-based access control
- Notice expiry automation

## 📱 Screenshots

### Landing Page
Beautiful gradient background with feature highlights

### Login Page
Clean login form with role selection

### Admin Dashboard
Comprehensive notice management interface with creation form and table view

### Student Dashboard
Card-based notice display with filtering and search capabilities

### Mobile View
Fully responsive design that works on all devices

## 🔄 Navigation Flow

```
index.html
    ↓
auth/login.html
    ↓
    ├─→ admin/admin-dashboard.html (if Admin role selected)
    └─→ student/student-dashboard.html (if Student role selected)
```

## 💻 Development Notes

- All HTML files can be opened directly in a browser
- No build process required
- Single CSS file for easy maintenance
- JavaScript used for basic interactivity (no framework)
- Backend integration will be added in future phases

## 🎓 Educational Project

This is a beginner-friendly full-stack project designed for learning:
- Clean, commented code
- Progressive development approach
- No unnecessary complexity
- Focus on fundamentals

## 📄 License

This project is for educational purposes.

## 👥 Contributors

- Project developed as part of a full-stack learning initiative

## 🔮 Roadmap

- [x] Phase 1: Frontend UI Design
- [ ] Phase 2: Backend Setup (Flask)
- [x] Phase 3: Database Schema (Oracle SQL)
- [ ] Phase 4: Authentication & Authorization
- [ ] Phase 5: Email Notifications
- [ ] Phase 6: Deployment

---

**Note**: Frontend UI and database schema are complete. Backend integration and authentication logic will be added in subsequent development phases.