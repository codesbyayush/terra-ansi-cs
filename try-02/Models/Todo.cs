using System.ComponentModel.DataAnnotations.Schema;

namespace Models
{
    [Table("todos")]
    public class Todo
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("content")]
        public string Content { get; set; }

        [Column("email")]
        public string? Email { get; set; }
    }
}