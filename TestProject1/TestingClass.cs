using lab5connorcole.Services;
using lab5connorcole.Data;
using System.Net;
namespace TestProject1
{



    [TestClass]
    public class TestingClass
    {
        [TestMethod]

        public void TestAddBookSuccess()
        {
            //Arrange
            LibraryService libraryService = new LibraryService();
            string title = "test";
            string author = "test";
            string isbn = "test";

            //Act
            libraryService.AddBook(title, author, isbn);
            Book book = libraryService.books.FirstOrDefault(b  => b.Title == title);

            //Assert

            Assert.IsTrue(libraryService.books.Contains(book));
            libraryService.DeleteBook(book.Id);

        }

 

        [TestMethod]
        public void TestEditBookSuccess()
        {
            //Arrange
            LibraryService libraryService = new LibraryService();
            string title = "test2ah";
            string author = "test2ah";
            string isbn = "test2ah";
            libraryService.AddBook("title3", "author3", "isbn3");
            Book book = libraryService.books.FirstOrDefault(b => b.Title == "title3");
            int id = book.Id;

            //Act

            
            libraryService.EditBook(id, title, author, isbn);

            //Assert
            Book book2 = libraryService.books.FirstOrDefault(b => b.Title == title);

            Assert.IsTrue(libraryService.books.Contains(book2));
            libraryService.DeleteBook(id);
        }
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void TestEditBookFail()
        {
            //Arrange
            LibraryService libraryService = new LibraryService();
            string title = "test2";
            string author = "test2";
            string isbn = "test2";
            int id = 1003;

            //Act

            libraryService.AddBook("title", "author", "isbn");
            libraryService.EditBook(id, title, author, isbn);

            //Assert
            Assert.IsFalse(libraryService.books[1002].Title == title);


            }

            [TestMethod]
        public void TestDeleteBookSuccess()
        {

            //Arrange
            LibraryService libraryService = new LibraryService();
            string title = "test2..";
            string author = "test2..";
            string isbn = "test2..";
            libraryService.AddBook(title, author, isbn);
            Book book = libraryService.books.FirstOrDefault(b => b.Title == title);
            int id = book.Id;

            //Act

            libraryService.DeleteBook(id);

            Assert.IsTrue(!libraryService.books.Contains(book));
        }

        [TestMethod]
        public void TestDeleteBookFail()
        {

            //Arrange
            LibraryService libraryService = new LibraryService();
            string title = "test2";
            string author = "test2";
            string isbn = "test2";
            int id = 90000;
            Book book = libraryService.books.FirstOrDefault(b => b.Id == id);

            //Act

            libraryService.DeleteBook(id);

            //Assert
            Assert.IsTrue(!libraryService.books.Contains(book));
        }

        [TestMethod]

        public void ListBookFail()
        {
            //Arrange
            LibraryService service = new LibraryService();
            service.books.Clear();

            //Act
            List<Book> test = service.ListBooks();

            //Assert
            Assert.IsFalse(test.Count > 0);
        }

        [TestMethod]
        public void AddUserSuccess()
        {
            //Arrange
            LibraryService service = new LibraryService();
            string name = "test user1";
            string email = "test email 1";

            //Act
            service.AddUser(name, email);

            //Assert
            User user = service.users.FirstOrDefault(u => u.Name == name);
            Assert.IsTrue(service.users.Contains(user));
            service.DeleteUser(user.Id);

        }

        
   

        [TestMethod]

        public void ListUserFail()
        {

            //Arrange
            LibraryService service = new LibraryService();
            service.users.Clear();

            //Act
            List<User> test = service.ListUsers();

            //Assert
            Assert.IsFalse(test.Count > 0);
        }
    }
}
