# Redmineflux Mentions Plugin

[![Redmine 7.0 Ready](https://img.shields.io/badge/Redmine-5.x%20%7C%206.x%20%7C%207.x-blue.svg)](https://www.redmine.org)
[![Ruby 3.x](https://img.shields.io/badge/Ruby-3.x%20%7C%204.x-red.svg)](https://www.ruby-lang.org)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL%202.0-yellow.svg)](https://opensource.org/licenses/GPL-2.0)

**Author:** Arean Narrayan ([@Arean82](https://github.com/Arean82))  
**Repository:** [https://github.com/Arean82/flux_mentions](https://github.com/Arean82/flux_mentions)  

The Mentions Plugin brings user and group mentions to Redmine, enabling collaboration and communication across your team. Users can mention colleagues and teams in issue descriptions, journals/notes, and wiki pages with autocomplete suggestions, visual chips, email alerts, and custom issue query filters.

---

![Issue Mention](issue_mention_user.png)
![Mention User](mention_user.png)
![Plugin Configuration](plugin_config.png)

---

## 🚀 Key Features in Version 6.4.0

* **🔍 Issue Query Filter ("Mentioned user"):** Filter issues list by `Mentioned user = me` or any user/group to quickly find every issue where you or a colleague was mentioned.
* **👤 Per-User Notification Preferences:** Individual users can control whether they receive mention emails directly in **My Account** → **Preferences**.
* **👥 Group Mentions (`@developers`, `@support`):** Mention entire teams. Notifies all members of that group with email addresses simultaneously.
* **🎨 Visual Mention Chips:** Automatically formats mentions into styled user and group chips with distinct colors and profile links in rendered markdown and textile.
* **⚡ Autocomplete Suggestions:** Clean autocomplete powered by Tribute.js displaying user full names, logins, and group indicators.
* **📧 Instant Email Notifications:** Automatically dispatches email notifications to mentioned users and group members when issues are created or updated, and wiki pages are saved.
* **⚙️ Modern Administration Interface:** Redmine-native settings interface with toggles for group mentions, visual chips, and email dispatches.
* **Full Redmine 7.x & Rails 7 Compatibility:** Completely refactored for Zeitwerk autoloading using safe `to_prepare` hook loading.

---

## 📋 Compatibility

* **Redmine:** 5.0.x, 5.1.x, 6.0.x, and **Redmine 7.0.x**
* **Ruby:** 3.0, 3.1, 3.2, 3.3, 4.0
* Tested in production environments on Redmine 7.0.3

---

## 🛠️ Installation Instructions

> **Note:** Always run `bundle` and `rake` commands from the **Redmine root directory**, never from inside the plugin directory.

### 1. Clone the repository
Navigate to your Redmine `plugins` folder and clone the repository:

```bash
cd /data/redmine/plugins
git clone https://github.com/Arean82/flux_mentions.git
```

### 2. Configure Bundler & Dependencies
From your Redmine root directory:

```bash
cd /data/redmine
bundle config set --local without 'development test'
bundle install
```

### 3. Run Database Migrations
Run the plugin database migrations from the Redmine root directory:

```bash
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

### 4. Restart Redmine
Restart your Redmine application server (e.g., Puma, Passenger, or systemd):

```bash
sudo systemctl restart redmine
```

---

## 📖 Usage

### Mentioning Users and Groups
* In any issue description, note, or wiki page, type `@` (or your configured symbol).
* Start typing a name, login, or group name. Select from the dropdown list.
* Upon saving, all mentioned users (and group members) receive instant email notifications.

### Filtering Issues by Mentions
* Navigate to **Issues**.
* Expand **Add filter** and select **Mentioned user**.
* Choose **<< me >>** to see all issues where you have been tagged in descriptions or notes!

### Managing Notification Preferences
* Click **My account** (top right).
* Under **Mentions**, toggle **"Email notifications for mentions"** on or off.

---

## 📄 License

This plugin is available under the GNU General Public License v2 (GPL-2.0).
