using System;
using System.Collections.Generic;

namespace Api.Models {
    public class Deck {
        public Guid Id { get; set; }

        public string Name { get; set; }

        public IList<string> Houses { get; set; }

        public int Chains { get; set; }
    }
}