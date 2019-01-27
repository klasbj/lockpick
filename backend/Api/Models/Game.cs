using System;
using System.Collections.Generic;

namespace Api.Models {
    public class Game {
        public Guid Id { get; set; }

        public IList<PlayerData> Players { get; set; }

        public GameState State { get; set; }

        public Player Winner { get; set; }

        public enum GameState {
            Finished,
            InProgress
        }

        public class PlayerData {
            public Player Player { get; set; }

            public string Deck { get; set; }

            public int Chains { get; set; }
        }
    }
}