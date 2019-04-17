using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Api.Models;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class MatchesController : ControllerBase {
        // GET api/matches
        [HttpGet]
        public ActionResult<IEnumerable<Match>> Get() {
            return Ok(GetMatches());
        }

        // GET api/matches/5
        [HttpGet("{id}")]
        public ActionResult<Match> Get(Guid id) {
            var match = GetMatches(id).FirstOrDefault();

            if (match == null) {
                return NotFound();
            }

            return Ok(match);
        }

        private IEnumerable<Match> GetMatches(Guid? id = null) {
            var players = new byte[] { 0, 1, 2 }.Select(x => new Player {
                Id = GenGuid(1, x), Name = $"Player{x}"
            }).ToList();

            var decks = new byte[] { 0, 1, 2 }.Select(x => new Deck {
                Id = GenGuid(2, x), Name = $"Deck{x}",
                Chains = x, Houses = new[] { "Dis", "Sanctum", "Logos" }
            }).ToList();

            return new Match[] {
                new Match {
                    Id = GenGuid(3, 0),
                    Format = Format.Archon,
                    Variant = new Variant {
                        Type = "bestof",
                        NumGames = 3,
                        Players = new[] {
                            new MatchPlayer {
                                Player = players[0],
                                Deck = decks[0]
                            },
                            new MatchPlayer {
                                Player = players[1],
                                Deck = decks[1]
                            }
                        }
                    },
                    Games = new[] {
                        new Game {
                            Id = GenGuid(4, 0),
                            State = Game.GameState.Finished,
                            Winner = players[0],
                            Players = new[] {
                                new Game.PlayerData { Player = players[0], Deck = decks[0], Chains = 0 },
                                new Game.PlayerData { Player = players[1], Deck = decks[1], Chains = 0 },
                            },
                            Time = new DateTime(2019, 2, 18, 16, 33, 25)
                        },
                        new Game {
                            Id = GenGuid(4, 1),
                            State = Game.GameState.Finished,
                            Winner = players[1],
                            Players = new[] {
                                new Game.PlayerData { Player = players[1], Deck = decks[0], Chains = 0 },
                                new Game.PlayerData { Player = players[0], Deck = decks[1], Chains = 0 },
                            },
                            Time = new DateTime(2019, 2, 18, 16, 48, 57)
                        },
                        new Game {
                            Id = GenGuid(4, 2),
                            State = Game.GameState.Finished,
                            Winner = players[0],
                            Players = new[] {
                                new Game.PlayerData { Player = players[0], Deck = decks[0], Chains = 7 },
                                new Game.PlayerData { Player = players[1], Deck = decks[1], Chains = 0 },
                            },
                            Time = new DateTime(2019, 2, 18, 16, 59, 59)
                        },
                    }
                }
            }.Where(x => id == null || x.Id == id);
        }

        private Guid GenGuid(byte t, byte i) {
            return new Guid(Enumerable.Repeat<byte>(0, 14).Concat(new[] { t, i }).ToArray());
        }
    }
}
