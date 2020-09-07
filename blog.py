from flask import Flask, render_template,flash,redirect,url_for,session,logging,request
from flask_mysqldb import MySQL
from wtforms import Form,StringField,TextAreaField, PasswordField,validators
from passlib.hash import sha256_crypt
from functools import wraps 



# user login decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if "logged_in" in session:

            return f(*args, **kwargs)
        else:
            flash("Please login to view the page. If you are not a member, you can register","danger")
            return redirect(url_for("login"))
    return decorated_function
# user register form
class RegisterForm(Form):
    name=StringField("Name and Family Name",validators=[validators.length(min=3,max=20)])
    username=StringField("User Name",validators=[validators.length(min=3,max=35)])
    email=StringField("E-mail Address",validators=[validators.Email(message="Please enter a valid email address")])
    password = PasswordField(" Password", validators=[
        validators.DataRequired(message="please enter a password"),
        validators.EqualTo(fieldname="confirm", message="password did not match")
    ])
    confirm = PasswordField("Password Match")

class LoginForm(Form): 
    username = StringField("User Name")
    password = PasswordField("Password")

app = Flask(__name__)
app.secret_key="blog"

app.config["MYSQL_HOST"] = "Localhost"
app.config["MYSQL_USER"] = "root"
app.config["MYSQL_PASSWORD"] = ""
app.config["MYSQL_DB"] = "blog"
app.config["MYSQL_CURSORCLASS"] = "DictCursor"

mysql= MySQL(app)

@app.route("/")
def index():
      

    return render_template("index.html")

#about
@app.route("/about")
def about():
   
    return render_template("about.html")


#for register

@app.route("/register", methods = ["GET","POST"] )
def register():
    form = RegisterForm(request.form)
    if request.method=="POST" and form.validate():
        name =form.name.data
        username=form.username.data
        email=form.email.data
        password= sha256_crypt.encrypt(form.password.data)

        cursor = mysql.connection.cursor()
        
        sorgu = "Insert into users (name,email,username,password) VALUES(%s,%s,%s,%s)"

        cursor.execute(sorgu,(name,email,username,password))
        mysql.connection.commit()

        cursor.close()
        flash("register was okay", "info")

        return redirect(url_for("login"))
    else:
        return render_template("register.html", form=form)


# login
@app.route("/login", methods=["GET","POST"])
def login():
    form = LoginForm(request.form)
    if request.method=="POST":
        username= form.username.data
        password_entered= form.password.data
  

        cursor = mysql.connection.cursor()
        
        sorgu = "Select * from users where username  = %s"
        
        result = cursor.execute(sorgu,(username,))

        if result > 0:
            data = cursor.fetchone()
            real_password = data["password"]
            if sha256_crypt.verify(password_entered,real_password):
                flash("Login is success"  ,"success")

                session["logged_in"]= True
                session["username"]= username

                return redirect(url_for("index"))
            else:
                flash("password is not true","danger")
                return redirect(url_for("login"))

        else:
            flash("Username is not true","danger")
            return redirect(url_for("login"))



    return render_template("login.html", form=form)

# log out
@app.route("/logout")
def logout():

    session.clear()
    return redirect(url_for("index"))

# Control Panel
@app.route("/dashboard")
@login_required
def dashboard():
    cursor = mysql.connection.cursor()
    sorgu="select * from articles where author =%s"

    result = cursor.execute(sorgu,(session["username"],))

    if result > 0:
        articles=cursor.fetchall()
        return render_template("dashboard.html" , articles = articles)

    else:
        return render_template("dashboard.html")

    

    

#article push
@app.route("/addarticle", methods=["GET","POST"])
def addarticle():
    form =ArticleForm(request.form)
    if request.method=="POST" and form.validate():
        title=form.title.data
        content=form.content.data


        cursor = mysql.connection.cursor()
        
        sorgu = "Insert into articles(title,author,content)  VALUES(%s,%s,%s)"
        
        cursor.execute(sorgu,(title,session["username"],content))

        mysql.connection.commit()
        cursor.close()

        flash("article Add Success", "success")


        return redirect(url_for("dashboard"))


    return render_template("addarticle.html",form=form)
#article form
class ArticleForm(Form):
    title= StringField("Article Title", validators=[validators.length(min=5,max=100)])
    content= TextAreaField("Article Content", validators=[validators.length(min=10)])
# Article page
@app.route("/articles")
def articles():
    cursor = mysql.connection.cursor()
    sorgu="select * from articles"

    result=cursor.execute(sorgu,)
 
    if result>0:
        articles = cursor.fetchall()
        return render_template("articles.html",articles=articles)

    else:
        return render_template("articles.html")


#detail page
@app.route("/article/<string:id>")
def article(id):
    cursor=mysql.connection.cursor()

    sorgu = "select * from articles where id=%s"

    result = cursor.execute(sorgu,(id),)

    if result>0:
       article = cursor.fetchone()
       return render_template("article.html",article=article)
    else:
        return render_template("article.html")
#Article Delete
@app.route("/delete/<string:id>")
@login_required
def delete(id):
    cursor=mysql.connection.cursor()

    sorgu = "select * from articles where author=%s and id=%s"

    result = cursor.execute(sorgu,(session["username"],id))

    if result>0:
       sorgu2="Delete from articles where id=%s"

       cursor.execute(sorgu2,(id,))

       mysql.connection.commit()
       return render_template("dashboard.html")
    
    else:
        flash("there is no such article or you are not authorized to do this","warning")
        return render_template("index.html")
#Article Update
@app.route("/edit/<string:id>", methods=["GET","POST"])
@login_required
def update(id):

    if request.method=="GET":
        cursor=mysql.connection.cursor()
        sorgu = "select * from articles where id=%s and author=%s"
        result = cursor.execute(sorgu,(id,session["username"]))

        if result==0:
            flash("there is no such article or you are not authorized to do this","warning")
            return redirect(url_for("index"))
        
        else:
            article = cursor.fetchone()
            form = ArticleForm()

            form.title.data = article["title"]
            form.content.data=article["content"]
            return render_template("update.html",form=form)
    else:
        #post request
        form = ArticleForm(request.form)

        newTitle=form.title.data
        newContent=form.content.data

        sorgu2="Update articles set title =%s, content=%s where id=%s"

        cursor=mysql.connection.cursor()

        cursor.execute(sorgu2,(newTitle,newContent,id))
    
        mysql.connection.commit()

        flash("Article Update Success", "success")

        return redirect(url_for("dashboard"))
    

		


if __name__ == "__main__":
    app.run(debug=True)

