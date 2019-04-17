using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Api.Models {
    public class Game {
        public Guid Id { get; set; }

        public IList<PlayerData> Players { get; set; }

        public GameState State { get; set; }

        public Player Winner { get; set; }

        public DateTime Time { get; set; }

        [JsonConverter(typeof(StringEnumConverter))]
        public enum GameState {
            Finished,
            InProgress
        }

        public class PlayerData {
            public Player Player { get; set; }

            public Deck Deck { get; set; }

            public int Chains { get; set; }
        }
    }
}