using Microsoft.AspNetCore.Mvc;
using Data;
using Models;
using Microsoft.EntityFrameworkCore;

namespace try_02.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TodosController : ControllerBase
    {
        private readonly TodoContext _context;

        public TodosController(TodoContext todoContext)
        {
            _context = todoContext;
        }


        [HttpGet(Name = "getTodos")]
        public async Task<ActionResult<IEnumerable<Todo>>> Get()
        {
            var todos = await _context.Todos.ToListAsync();
            return todos;
        }

        [HttpPost]
        public async Task<ActionResult<Todo>> Post(Todo todo)
        {
            await _context.Todos.AddAsync(todo);
            await _context.SaveChangesAsync();
            return todo;
        }
    }
}
