class Technician {
  final String name;
  final int id;
  const Technician(this.id, this.name);
}

class Technicians {
  List<Technician> staff() {
    return <Technician>[
      const Technician(1, "Sherwin Sandoval"),
      const Technician(2, "Sherwin Sandoval 1"),
    ];
  }
}
