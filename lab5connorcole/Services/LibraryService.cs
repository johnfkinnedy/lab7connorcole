using lab5connorcole.Data;
using static System.Reflection.Metadata.BlobBuilder;

namespace lab5connorcole.Services
{
    public class LibraryService : ILibraryService
    {
        public List<Book> books { get; set; } = new List<Book>();
        public List<User> users { get; set; } = new List<User>();
        public Dictionary<User, List<Book>> borrowedBooks { get; set; } = new Dictionary<User, List<Book>>();
        //read books from a file


        public LibraryService()
        {
            ReadBooks();
            ReadUsers();
        }
        public void ReadBooks()
        {
            try
            {
                foreach (var line in File.ReadLines("Data\\Books.csv"))
                {
                    var fields = line.Split(',');
                    if (fields.Length >= 4)
                    {
                        var book = new Book
                        {
                            Id = int.Parse(fields[0].Trim()),
                            Title = fields[1].Trim(),
                            Author = fields[2].Trim(),
                            ISBN = fields[3].Trim()
                        };

                        books.Add(book);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occured: {ex.Message}");

            }
        }
        public void ReadUsers()
        {
            try
            {
                foreach (var line in File.ReadLines("Data\\Users.csv"))
                {

                    var fields = line.Split(',');

                    if (fields.Length >= 3) // Ensure there are enough fields
                    {
                        var user = new User
                        {
                            Id = int.Parse(fields[0].Trim()),
                            Name = fields[1].Trim(),
                            Email = fields[2].Trim()
                        };

                        users.Add(user);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }
        }

        public async void AddBook(string title, string author, string isbn)
        {
            int id = books.Any() ? books.Max(b => b.Id) + 1 : 1;
            books.Add(new Book { Id = id, Title = title, Author = author, ISBN = isbn });

            UpdateBookList();

        }

        public async void EditBook(int bookId, string newTitle, string newAuthor, string newIsbn)
        {
            Book book = books.FirstOrDefault(b => b.Id == bookId);

            if (book != null)
            {
                if (!string.IsNullOrEmpty(newTitle)) book.Title = newTitle;
                if (!string.IsNullOrEmpty(newAuthor)) book.Author = newAuthor;
                if (!string.IsNullOrEmpty(newIsbn)) book.ISBN = newIsbn;
            }


            UpdateBookList();
        }

        public async void DeleteBook(int bookId)
        {
            Book book = books.FirstOrDefault(b => b.Id == bookId);
            if (book.Id > books.Count)
            {
                throw new NotImplementedException();
            }

            if (book != null)
            {
                books.Remove(book);
            }

            UpdateBookList();
        }

        public List<Book> ListBooks()
        {
            return books;

        }

        public async void UpdateBookList()
        {
            using (var writer = new StreamWriter("Data\\Books.csv"))
            {
                foreach (Book book in books)
                {
                    string str = $"{book.Id.ToString()}, {book.Title}, {book.Author}, {book.ISBN}";
                    await writer.WriteLineAsync(str);
                }
            }
        }

        //user methods

        public async void AddUser(string name, string email)
        {
            int id = users.Any() ? users.Max(u => u.Id) + 1 : 1;
            users.Add(new User { Id = id, Name = name, Email = email });
            UpdateUserList();
        }

        public async void EditUser(int userId, string newName, string newEmail)
        {
            User user = users.FirstOrDefault(u => u.Id == userId);

            if (user != null)
            {
                {
                    if (!string.IsNullOrEmpty(newName)) user.Name = newName;
                    if (!string.IsNullOrEmpty(newEmail)) user.Email = newEmail;
                }
                UpdateUserList();
            }
        }
        public async void DeleteUser(int userId)
        {
            User user = users.FirstOrDefault(u => u.Id == userId);
            if (user != null)
            {
                users.Remove(user);
            }
            UpdateUserList();
        }

        public List<User> ListUsers()
        {
            return users;
        }

        async void UpdateUserList()
        {
            using (var writer = new StreamWriter("Data\\Users.csv"))
                foreach (User user in users)
                {
                    string str = $"{user.Id.ToString()}, {user.Name}, {user.Email}";
                    await writer.WriteLineAsync(str);
                }
        }



        //borrow methods

        public async void BorrowBook(int bookId, int userId)
        {
            Book book = books.FirstOrDefault(b => b.Id == bookId);
            User user = users.FirstOrDefault(u => u.Id == userId);
            if (user != null && book != null)
            {
                if (!borrowedBooks.ContainsKey(user))
                {
                    borrowedBooks[user] = new List<Book>();
                }
                borrowedBooks[user].Add(book);
                books.Remove(book);
                UpdateBookList();
            }

        }

        public async void ReturnBook(int bookNum, int userId)
        {
            User user = users.FirstOrDefault(u => u.Id == userId);
            //need to list books with numbers by user

            if (user != null && borrowedBooks.ContainsKey(user) && borrowedBooks[user].Count > 0)
            {
                Book bookToReturn = borrowedBooks[user][bookNum -1];
                borrowedBooks[user].RemoveAt(bookNum - 1);
                books.Add(bookToReturn);
                UpdateBookList();
            }
        }

        public Dictionary<User, List<Book>> ListBorrowedBooks()
        {
            return borrowedBooks;
        }


    }
}


