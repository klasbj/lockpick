using Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Api.Data {
    public class LockpickDbContext : DbContext {
        public DbSet<Player> Players;

        public DbSet<Game> Games { get; set; }
    }
}