-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Anamakine: localhost
-- Üretim Zamanı: 07 Eyl 2020, 11:21:25
-- Sunucu sürümü: 10.4.14-MariaDB
-- PHP Sürümü: 7.2.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `blog`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `articles`
--

CREATE TABLE `articles` (
  `id` int(11) NOT NULL,
  `title` text NOT NULL,
  `author` text NOT NULL,
  `content` text NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `articles`
--

INSERT INTO `articles` (`id`, `title`, `author`, `content`, `created_date`) VALUES
(5, 'blog.py(The python code of this block)', 'hasann', '<p>deneme kodu</p>\r\n\r\n<p>&nbsp;</p>\r\n\r\n<pre class=\"prettyprint\">\r\nfrom flask import Flask, render_template,flash,redirect,url_for,session,logging,request\r\nfrom flask_mysqldb import MySQL\r\nfrom wtforms import Form,StringField,TextAreaField, PasswordField,validators\r\nfrom passlib.hash import sha256_crypt\r\nfrom functools import wraps \r\n\r\n# user login decorator\r\ndef login_required(f):\r\n    @wraps(f)\r\n    def decorated_function(*args, **kwargs):\r\n        if &quot;logged_in&quot; in session:\r\n\r\n            return f(*args, **kwargs)\r\n        else:\r\n            flash(&quot;Please login to view the page. If you are not a member, you can register&quot;,&quot;danger&quot;)\r\n            return redirect(url_for(&quot;login&quot;))\r\n    return decorated_function\r\n# user register form\r\nclass RegisterForm(Form):\r\n    name=StringField(&quot;Name and Family Name&quot;,validators=[validators.length(min=3,max=20)])\r\n    username=StringField(&quot;User Name&quot;,validators=[validators.length(min=3,max=35)])\r\n    email=StringField(&quot;E-mail Address&quot;,validators=[validators.Email(message=&quot;Please enter a valid email address&quot;)])\r\n    password = PasswordField(&quot; Password&quot;, validators=[\r\n        validators.DataRequired(message=&quot;please enter a password&quot;),\r\n        validators.EqualTo(fieldname=&quot;confirm&quot;, message=&quot;password did not match&quot;)\r\n    ])\r\n    confirm = PasswordField(&quot;Password Match&quot;)\r\n\r\nclass LoginForm(Form): \r\n    username = StringField(&quot;User Name&quot;)\r\n    password = PasswordField(&quot;Password&quot;)\r\n\r\napp = Flask(__name__)\r\napp.secret_key=&quot;blog&quot;\r\n\r\napp.config[&quot;MYSQL_HOST&quot;] = &quot;Localhost&quot;\r\napp.config[&quot;MYSQL_USER&quot;] = &quot;root&quot;\r\napp.config[&quot;MYSQL_PASSWORD&quot;] = &quot;&quot;\r\napp.config[&quot;MYSQL_DB&quot;] = &quot;blog&quot;\r\napp.config[&quot;MYSQL_CURSORCLASS&quot;] = &quot;DictCursor&quot;\r\n\r\nmysql= MySQL(app)\r\n\r\n@app.route(&quot;/&quot;)\r\ndef index():\r\n      \r\n\r\n    return render_template(&quot;index.html&quot;)\r\n\r\n#about\r\n@app.route(&quot;/about&quot;)\r\ndef about():\r\n   \r\n    return render_template(&quot;about.html&quot;)\r\n\r\n\r\n#for register\r\n\r\n@app.route(&quot;/register&quot;, methods = [&quot;GET&quot;,&quot;POST&quot;] )\r\ndef register():\r\n    form = RegisterForm(request.form)\r\n    if request.method==&quot;POST&quot; and form.validate():\r\n        name =form.name.data\r\n        username=form.username.data\r\n        email=form.email.data\r\n        password= sha256_crypt.encrypt(form.password.data)\r\n\r\n        cursor = mysql.connection.cursor()\r\n        \r\n        sorgu = &quot;Insert into users (name,email,username,password) VALUES(%s,%s,%s,%s)&quot;\r\n\r\n        cursor.execute(sorgu,(name,email,username,password))\r\n        mysql.connection.commit()\r\n\r\n        cursor.close()\r\n        flash(&quot;register was okay&quot;, &quot;info&quot;)\r\n\r\n        return redirect(url_for(&quot;login&quot;))\r\n    else:\r\n        return render_template(&quot;register.html&quot;, form=form)\r\n\r\n\r\n# login\r\n@app.route(&quot;/login&quot;, methods=[&quot;GET&quot;,&quot;POST&quot;])\r\ndef login():\r\n    form = LoginForm(request.form)\r\n    if request.method==&quot;POST&quot;:\r\n        username= form.username.data\r\n        password_entered= form.password.data\r\n  \r\n\r\n        cursor = mysql.connection.cursor()\r\n        \r\n        sorgu = &quot;Select * from users where username  = %s&quot;\r\n        \r\n        result = cursor.execute(sorgu,(username,))\r\n\r\n        if result &gt; 0:\r\n            data = cursor.fetchone()\r\n            real_password = data[&quot;password&quot;]\r\n            if sha256_crypt.verify(password_entered,real_password):\r\n                flash(&quot;Login is success&quot;  ,&quot;success&quot;)\r\n\r\n                session[&quot;logged_in&quot;]= True\r\n                session[&quot;username&quot;]= username\r\n\r\n                return redirect(url_for(&quot;index&quot;))\r\n            else:\r\n                flash(&quot;password is not true&quot;,&quot;danger&quot;)\r\n                return redirect(url_for(&quot;login&quot;))\r\n\r\n        else:\r\n            flash(&quot;Username is not true&quot;,&quot;danger&quot;)\r\n            return redirect(url_for(&quot;login&quot;))\r\n\r\n\r\n\r\n    return render_template(&quot;login.html&quot;, form=form)\r\n\r\n# log out\r\n@app.route(&quot;/logout&quot;)\r\ndef logout():\r\n\r\n    session.clear()\r\n    return redirect(url_for(&quot;index&quot;))\r\n\r\n# Control Panel\r\n@app.route(&quot;/dashboard&quot;)\r\n@login_required\r\ndef dashboard():\r\n    cursor = mysql.connection.cursor()\r\n    sorgu=&quot;select * from articles where author =%s&quot;\r\n\r\n    result = cursor.execute(sorgu,(session[&quot;username&quot;],))\r\n\r\n    if result &gt; 0:\r\n        articles=cursor.fetchall()\r\n        return render_template(&quot;dashboard.html&quot; , articles = articles)\r\n\r\n    else:\r\n        return render_template(&quot;dashboard.html&quot;)\r\n\r\n    \r\n\r\n    \r\n\r\n#article push\r\n@app.route(&quot;/addarticle&quot;, methods=[&quot;GET&quot;,&quot;POST&quot;])\r\ndef addarticle():\r\n    form =ArticleForm(request.form)\r\n    if request.method==&quot;POST&quot; and form.validate():\r\n        title=form.title.data\r\n        content=form.content.data\r\n\r\n\r\n        cursor = mysql.connection.cursor()\r\n        \r\n        sorgu = &quot;Insert into articles(title,author,content)  VALUES(%s,%s,%s)&quot;\r\n        \r\n        cursor.execute(sorgu,(title,session[&quot;username&quot;],content))\r\n\r\n        mysql.connection.commit()\r\n        cursor.close()\r\n\r\n        flash(&quot;article Add Success&quot;, &quot;success&quot;)\r\n\r\n\r\n        return redirect(url_for(&quot;dashboard&quot;))\r\n\r\n\r\n    return render_template(&quot;addarticle.html&quot;,form=form)\r\n#article form\r\nclass ArticleForm(Form):\r\n    title= StringField(&quot;Article Title&quot;, validators=[validators.length(min=5,max=100)])\r\n    content= TextAreaField(&quot;Article Content&quot;, validators=[validators.length(min=10)])\r\n# Article page\r\n@app.route(&quot;/articles&quot;)\r\ndef articles():\r\n    cursor = mysql.connection.cursor()\r\n    sorgu=&quot;select * from articles&quot;\r\n\r\n    result=cursor.execute(sorgu,)\r\n \r\n    if result&gt;0:\r\n        articles = cursor.fetchall()\r\n        return render_template(&quot;articles.html&quot;,articles=articles)\r\n\r\n    else:\r\n        return render_template(&quot;articles.html&quot;)\r\n\r\n\r\n#detail page\r\n@app.route(&quot;/article/<string:id>&quot;)\r\ndef article(id):\r\n    cursor=mysql.connection.cursor()\r\n\r\n    sorgu = &quot;select * from articles where id=%s&quot;\r\n\r\n    result = cursor.execute(sorgu,(id),)\r\n\r\n    if result&gt;0:\r\n       article = cursor.fetchone()\r\n       return render_template(&quot;article.html&quot;,article=article)\r\n    else:\r\n        return render_template(&quot;article.html&quot;)\r\n#Article Delete\r\n@app.route(&quot;/delete/<string:id>&quot;)\r\n@login_required\r\ndef delete(id):\r\n    cursor=mysql.connection.cursor()\r\n\r\n    sorgu = &quot;select * from articles where author=%s and id=%s&quot;\r\n\r\n    result = cursor.execute(sorgu,(session[&quot;username&quot;],id))\r\n\r\n    if result&gt;0:\r\n       sorgu2=&quot;Delete from articles where id=%s&quot;\r\n\r\n       cursor.execute(sorgu2,(id,))\r\n\r\n       mysql.connection.commit()\r\n       return render_template(&quot;dashboard.html&quot;)\r\n    \r\n    else:\r\n        flash(&quot;there is no such article or you are not authorized to do this&quot;,&quot;warning&quot;)\r\n        return render_template(&quot;index.html&quot;)\r\n#Article Update\r\n@app.route(&quot;/edit/<string:id>&quot;, methods=[&quot;GET&quot;,&quot;POST&quot;])\r\n@login_required\r\ndef update(id):\r\n\r\n    if request.method==&quot;GET&quot;:\r\n        cursor=mysql.connection.cursor()\r\n        sorgu = &quot;select * from articles where id=%s and author=%s&quot;\r\n        result = cursor.execute(sorgu,(id,session[&quot;username&quot;]))\r\n\r\n        if result==0:\r\n            flash(&quot;there is no such article or you are not authorized to do this&quot;,&quot;warning&quot;)\r\n            return redirect(url_for(&quot;index&quot;))\r\n        \r\n        else:\r\n            article = cursor.fetchone()\r\n            form = ArticleForm()\r\n\r\n            form.title.data = article[&quot;title&quot;]\r\n            form.content.data=article[&quot;content&quot;]\r\n            return render_template(&quot;update.html&quot;,form=form)\r\n    else:\r\n        #post request\r\n        form = ArticleForm(request.form)\r\n\r\n        newTitle=form.title.data\r\n        newContent=form.content.data\r\n\r\n        sorgu2=&quot;Update articles set title =%s, content=%s where id=%s&quot;\r\n\r\n        cursor=mysql.connection.cursor()\r\n\r\n        cursor.execute(sorgu2,(newTitle,newContent,id))\r\n    \r\n        mysql.connection.commit()\r\n\r\n        flash(&quot;Article Update Success&quot;, &quot;success&quot;)\r\n\r\n        return redirect(url_for(&quot;dashboard&quot;))\r\n    \r\n\r\n\r\n      \r\n\r\n\r\nif __name__ == &quot;__main__&quot;:\r\n    app.run(debug=True)\r\n\r\n</string:id></string:id></string:id></pre>\r\n', '2020-09-07 07:26:02'),
(6, 'blog.py(The python code of this blog)', 'sungur', '<pre class=\"prettyprint\">\r\n\r\nfrom flask import Flask, render_template,flash,redirect,url_for,session,logging,request\r\n\r\nfrom flask_mysqldb import MySQL\r\n\r\nfrom wtforms import Form,StringField,TextAreaField, PasswordField,validators\r\n\r\nfrom passlib.hash import sha256_crypt\r\n\r\nfrom functools import wraps\r\n\r\n\r\n\r\n# user login decorator\r\n\r\ndef login_required(f):\r\n\r\n@wraps(f)\r\n\r\ndef decorated_function(*args, **kwargs):\r\n\r\nif &quot;logged_in&quot; in session:\r\n\r\n\r\n\r\nreturn f(*args, **kwargs)\r\n\r\nelse:\r\n\r\nflash(&quot;Please login to view the page. If you are not a member, you can register&quot;,&quot;danger&quot;)\r\n\r\nreturn redirect(url_for(&quot;login&quot;))\r\n\r\nreturn decorated_function\r\n\r\n# user register form\r\n\r\nclass RegisterForm(Form):\r\n\r\nname=StringField(&quot;Name and Family Name&quot;,validators=[validators.length(min=3,max=20)])\r\n\r\nusername=StringField(&quot;User Name&quot;,validators=[validators.length(min=3,max=35)])\r\n\r\nemail=StringField(&quot;E-mail Address&quot;,validators=[validators.Email(message=&quot;Please enter a valid email address&quot;)])\r\n\r\npassword = PasswordField(&quot; Password&quot;, validators=[\r\n\r\nvalidators.DataRequired(message=&quot;please enter a password&quot;),\r\n\r\nvalidators.EqualTo(fieldname=&quot;confirm&quot;, message=&quot;password did not match&quot;)\r\n\r\n])\r\n\r\nconfirm = PasswordField(&quot;Password Match&quot;)\r\n\r\n\r\n\r\nclass LoginForm(Form):\r\n\r\nusername = StringField(&quot;User Name&quot;)\r\n\r\npassword = PasswordField(&quot;Password&quot;)\r\n\r\n\r\n\r\napp = Flask(__name__)\r\n\r\napp.secret_key=&quot;blog&quot;\r\n\r\n\r\n\r\napp.config[&quot;MYSQL_HOST&quot;] = &quot;Localhost&quot;\r\n\r\napp.config[&quot;MYSQL_USER&quot;] = &quot;root&quot;\r\n\r\napp.config[&quot;MYSQL_PASSWORD&quot;] = &quot;&quot;\r\n\r\napp.config[&quot;MYSQL_DB&quot;] = &quot;blog&quot;\r\n\r\napp.config[&quot;MYSQL_CURSORCLASS&quot;] = &quot;DictCursor&quot;\r\n\r\n\r\n\r\nmysql= MySQL(app)\r\n\r\n\r\n\r\n@app.route(&quot;/&quot;)\r\n\r\ndef index():\r\n\r\n\r\n\r\nreturn render_template(&quot;index.html&quot;)\r\n\r\n\r\n\r\n#about\r\n\r\n@app.route(&quot;/about&quot;)\r\n\r\ndef about():\r\n\r\nreturn render_template(&quot;about.html&quot;)\r\n\r\n\r\n\r\n\r\n#for register\r\n\r\n\r\n\r\n@app.route(&quot;/register&quot;, methods = [&quot;GET&quot;,&quot;POST&quot;] )\r\n\r\ndef register():\r\n\r\nform = RegisterForm(request.form)\r\n\r\nif request.method==&quot;POST&quot; and form.validate():\r\n\r\nname =form.name.data\r\n\r\nusername=form.username.data\r\n\r\nemail=form.email.data\r\n\r\npassword= sha256_crypt.encrypt(form.password.data)\r\n\r\n\r\n\r\ncursor = mysql.connection.cursor()\r\n\r\nsorgu = &quot;Insert into users (name,email,username,password) VALUES(%s,%s,%s,%s)&quot;\r\n\r\n\r\n\r\ncursor.execute(sorgu,(name,email,username,password))\r\n\r\nmysql.connection.commit()\r\n\r\n\r\n\r\ncursor.close()\r\n\r\nflash(&quot;register was okay&quot;, &quot;info&quot;)\r\n\r\n\r\n\r\nreturn redirect(url_for(&quot;login&quot;))\r\n\r\nelse:\r\n\r\nreturn render_template(&quot;register.html&quot;, form=form)\r\n\r\n\r\n\r\n\r\n# login\r\n\r\n@app.route(&quot;/login&quot;, methods=[&quot;GET&quot;,&quot;POST&quot;])\r\n\r\ndef login():\r\n\r\nform = LoginForm(request.form)\r\n\r\nif request.method==&quot;POST&quot;:\r\n\r\nusername= form.username.data\r\n\r\npassword_entered= form.password.data\r\n\r\n\r\n\r\ncursor = mysql.connection.cursor()\r\n\r\nsorgu = &quot;Select * from users where username = %s&quot;\r\n\r\nresult = cursor.execute(sorgu,(username,))\r\n\r\n\r\n\r\nif result &gt; 0:\r\n\r\ndata = cursor.fetchone()\r\n\r\nreal_password = data[&quot;password&quot;]\r\n\r\nif sha256_crypt.verify(password_entered,real_password):\r\n\r\nflash(&quot;Login is success&quot; ,&quot;success&quot;)\r\n\r\n\r\n\r\nsession[&quot;logged_in&quot;]= True\r\n\r\nsession[&quot;username&quot;]= username\r\n\r\n\r\n\r\nreturn redirect(url_for(&quot;index&quot;))\r\n\r\nelse:\r\n\r\nflash(&quot;password is not true&quot;,&quot;danger&quot;)\r\n\r\nreturn redirect(url_for(&quot;login&quot;))\r\n\r\n\r\n\r\nelse:\r\n\r\nflash(&quot;Username is not true&quot;,&quot;danger&quot;)\r\n\r\nreturn redirect(url_for(&quot;login&quot;))\r\n\r\n\r\n\r\n\r\n\r\nreturn render_template(&quot;login.html&quot;, form=form)\r\n\r\n\r\n\r\n# log out\r\n\r\n@app.route(&quot;/logout&quot;)\r\n\r\ndef logout():\r\n\r\n\r\n\r\nsession.clear()\r\n\r\nreturn redirect(url_for(&quot;index&quot;))\r\n\r\n\r\n\r\n# Control Panel\r\n\r\n@app.route(&quot;/dashboard&quot;)\r\n\r\n@login_required\r\n\r\ndef dashboard():\r\n\r\ncursor = mysql.connection.cursor()\r\n\r\nsorgu=&quot;select * from articles where author =%s&quot;\r\n\r\n\r\n\r\nresult = cursor.execute(sorgu,(session[&quot;username&quot;],))\r\n\r\n\r\n\r\nif result &gt; 0:\r\n\r\narticles=cursor.fetchall()\r\n\r\nreturn render_template(&quot;dashboard.html&quot; , articles = articles)\r\n\r\n\r\n\r\nelse:\r\n\r\nreturn render_template(&quot;dashboard.html&quot;)\r\n\r\n\r\n\r\n\r\n\r\n#article push\r\n\r\n@app.route(&quot;/addarticle&quot;, methods=[&quot;GET&quot;,&quot;POST&quot;])\r\n\r\ndef addarticle():\r\n\r\nform =ArticleForm(request.form)\r\n\r\nif request.method==&quot;POST&quot; and form.validate():\r\n\r\ntitle=form.title.data\r\n\r\ncontent=form.content.data\r\n\r\n\r\n\r\n\r\ncursor = mysql.connection.cursor()\r\n\r\nsorgu = &quot;Insert into articles(title,author,content) VALUES(%s,%s,%s)&quot;\r\n\r\ncursor.execute(sorgu,(title,session[&quot;username&quot;],content))\r\n\r\n\r\n\r\nmysql.connection.commit()\r\n\r\ncursor.close()\r\n\r\n\r\n\r\nflash(&quot;article Add Success&quot;, &quot;success&quot;)\r\n\r\n\r\n\r\n\r\nreturn redirect(url_for(&quot;dashboard&quot;))\r\n\r\n\r\n\r\n\r\nreturn render_template(&quot;addarticle.html&quot;,form=form)\r\n\r\n#article form\r\n\r\nclass ArticleForm(Form):\r\n\r\ntitle= StringField(&quot;Article Title&quot;, validators=[validators.length(min=5,max=100)])\r\n\r\ncontent= TextAreaField(&quot;Article Content&quot;, validators=[validators.length(min=10)])\r\n\r\n# Article page\r\n\r\n@app.route(&quot;/articles&quot;)\r\n\r\ndef articles():\r\n\r\ncursor = mysql.connection.cursor()\r\n\r\nsorgu=&quot;select * from articles&quot;\r\n\r\n\r\n\r\nresult=cursor.execute(sorgu,)\r\n\r\nif result&gt;0:\r\n\r\narticles = cursor.fetchall()\r\n\r\nreturn render_template(&quot;articles.html&quot;,articles=articles)\r\n\r\n\r\n\r\nelse:\r\n\r\nreturn render_template(&quot;articles.html&quot;)\r\n\r\n\r\n\r\n\r\n#detail page\r\n\r\n@app.route(&quot;/article/<string:id>&quot;)\r\n\r\ndef article(id):\r\n\r\ncursor=mysql.connection.cursor()\r\n\r\n\r\n\r\nsorgu = &quot;select * from articles where id=%s&quot;\r\n\r\n\r\n\r\nresult = cursor.execute(sorgu,(id),)\r\n\r\n\r\n\r\nif result&gt;0:\r\n\r\narticle = cursor.fetchone()\r\n\r\nreturn render_template(&quot;article.html&quot;,article=article)\r\n\r\nelse:\r\n\r\nreturn render_template(&quot;article.html&quot;)\r\n\r\n#Article Delete\r\n\r\n@app.route(&quot;/delete/<string:id>&quot;)\r\n\r\n@login_required\r\n\r\ndef delete(id):\r\n\r\ncursor=mysql.connection.cursor()\r\n\r\n\r\n\r\nsorgu = &quot;select * from articles where author=%s and id=%s&quot;\r\n\r\n\r\n\r\nresult = cursor.execute(sorgu,(session[&quot;username&quot;],id))\r\n\r\n\r\n\r\nif result&gt;0:\r\n\r\nsorgu2=&quot;Delete from articles where id=%s&quot;\r\n\r\n\r\n\r\ncursor.execute(sorgu2,(id,))\r\n\r\n\r\n\r\nmysql.connection.commit()\r\n\r\nreturn render_template(&quot;dashboard.html&quot;)\r\n\r\nelse:\r\n\r\nflash(&quot;there is no such article or you are not authorized to do this&quot;,&quot;warning&quot;)\r\n\r\nreturn render_template(&quot;index.html&quot;)\r\n\r\n#Article Update\r\n\r\n@app.route(&quot;/edit/<string:id>&quot;, methods=[&quot;GET&quot;,&quot;POST&quot;])\r\n\r\n@login_required\r\n\r\ndef update(id):\r\n\r\n\r\n\r\nif request.method==&quot;GET&quot;:\r\n\r\ncursor=mysql.connection.cursor()\r\n\r\nsorgu = &quot;select * from articles where id=%s and author=%s&quot;\r\n\r\nresult = cursor.execute(sorgu,(id,session[&quot;username&quot;]))\r\n\r\n\r\n\r\nif result==0:\r\n\r\nflash(&quot;there is no such article or you are not authorized to do this&quot;,&quot;warning&quot;)\r\n\r\nreturn redirect(url_for(&quot;index&quot;))\r\n\r\nelse:\r\n\r\narticle = cursor.fetchone()\r\n\r\nform = ArticleForm()\r\n\r\n\r\n\r\nform.title.data = article[&quot;title&quot;]\r\n\r\nform.content.data=article[&quot;content&quot;]\r\n\r\nreturn render_template(&quot;update.html&quot;,form=form)\r\n\r\nelse:\r\n\r\n#post request\r\n\r\nform = ArticleForm(request.form)\r\n\r\n\r\n\r\nnewTitle=form.title.data\r\n\r\nnewContent=form.content.data\r\n\r\n\r\n\r\nsorgu2=&quot;Update articles set title =%s, content=%s where id=%s&quot;\r\n\r\n\r\n\r\ncursor=mysql.connection.cursor()\r\n\r\n\r\n\r\ncursor.execute(sorgu2,(newTitle,newContent,id))\r\n\r\nmysql.connection.commit()\r\n\r\n\r\n\r\nflash(&quot;Article Update Success&quot;, &quot;success&quot;)\r\n\r\n\r\n\r\nreturn redirect(url_for(&quot;dashboard&quot;))\r\n\r\n\r\n\r\n\r\n\r\n\r\nif __name__ == &quot;__main__&quot;:\r\n\r\napp.run(debug=True)\r\n\r\n\r\n\r\n\r\n</string:id></string:id></string:id></pre>\r\n', '2020-09-07 07:34:32');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `email` text NOT NULL,
  `username` text NOT NULL,
  `password` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `username`, `password`) VALUES
(8, 'Mustafa Sungur TAŞ', 'sunqurtas@gmail.com', 'sungur', '$5$rounds=535000$FqCqMdgj3dpFqOcT$PPjx6cBzM3O9ozyJbFJCdEXWKrQyZzO/Zz67zW9P9xA');

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id`);

--
-- Tablo için indeksler `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `articles`
--
ALTER TABLE `articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Tablo için AUTO_INCREMENT değeri `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;