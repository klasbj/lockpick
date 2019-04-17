using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Api.Models {
    [JsonConverter(typeof(StringEnumConverter))]
    public enum Format {
        Archon,
        Sealed
    }

    public class Variant {
        public string Type { get; set; }

        public int? NumGames { get; set; }

        public IList<MatchPlayer> Players { get; set; }
    }

    public class MatchPlayer {
        public Player Player { get; set; }

        public Deck Deck { get; set; }
    }

    public class Match {
        public Guid Id { get; set; }

        public Format Format { get; set; }

        public Variant Variant { get; set; }

        public IList<Game> Games { get; set; }
    }
}