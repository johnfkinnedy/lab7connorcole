using lab5connorcole.Data;
using System.ComponentModel;

namespace lab5connorcole.Services
{
    public interface ILibraryService
    {
        public static List<Book> books;
        public static List<User> users;
        public static Dictionary<User, List<Book>> borrowedBooks;
        //read books from a file
        void ReadBooks() { }

        //read users from a file
        void ReadUsers() { }

        void AddBook(string title, string author, string isbn) { }

        void EditBook(int bookId, string newTitle, string newAuthor, string newIsbn) { }

        void DeleteBook(int bookId) { }

        List<Book> ListBooks(){ return null; }
        //user methods

        void AddUser(string name, string email) { }

        void EditUser(int userId, string name, string email) { }

        void DeleteUser(int userId) { }

        List<User> ListUsers() { return null; }

        void BorrowBook(int bookId, int userId) { }

        void ReturnBook(int bookId, int userId) { }

        Dictionary<User, List<Book>> ListBorrowedBooks() { return null; }
    }
}
