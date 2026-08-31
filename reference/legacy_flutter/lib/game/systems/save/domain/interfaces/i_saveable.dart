abstract interface class ISaveable<T> {
  T toSaveData();

  void fromSaveData(T data);
}

// abstract interface class IResettable {
//   void reset();
// }

// abstract interface class IValidatable {
//   bool validate();
// }

// abstract interface class ISaveableManager<T>
//     implements ISaveable<T>, IResettable, IValidatable {}
