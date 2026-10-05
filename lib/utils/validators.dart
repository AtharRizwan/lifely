class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid() : isValid = true, errorMessage = null;
  const ValidationResult.invalid(this.errorMessage) : isValid = false;

  bool get isInvalid => !isValid;
}

class Validators {
  Validators._();

  static ValidationResult validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationResult.invalid('Task title is required.');
    }
    if (value.trim().length < 2) {
      return const ValidationResult.invalid('Task title must be at least 2 characters.');
    }
    if (value.trim().length > 100) {
      return const ValidationResult.invalid('Task title must be less than 100 characters.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validateTaskNotes(String? value) {
    if (value != null && value.length > 500) {
      return const ValidationResult.invalid('Notes must be less than 500 characters.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationResult.invalid('Email is required.');
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return const ValidationResult.invalid('Please enter a valid email.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return const ValidationResult.invalid('Password is required.');
    }
    if (value.length < 6) {
      return const ValidationResult.invalid('Password must be at least 6 characters.');
    }
    if (value.length > 50) {
      return const ValidationResult.invalid('Password must be less than 50 characters.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationResult.invalid('Name is required.');
    }
    if (value.trim().length < 2) {
      return const ValidationResult.invalid('Name must be at least 2 characters.');
    }
    if (value.trim().length > 50) {
      return const ValidationResult.invalid('Name must be less than 50 characters.');
    }
    // Letters from any script, plus spaces, apostrophes, dots and hyphens.
    final nameRegex = RegExp(r"^[\p{L}\p{M}\s.'\-]+$", unicode: true);
    if (!nameRegex.hasMatch(value.trim())) {
      return const ValidationResult.invalid('Name can only contain letters, spaces, apostrophes and hyphens.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validateMood(String? value) {
    const validMoods = ['Focused', 'Steady', 'Stressed', 'Low energy'];
    if (value == null || value.isEmpty) {
      return const ValidationResult.invalid('Please select a mood.');
    }
    if (!validMoods.contains(value)) {
      return const ValidationResult.invalid('Please select a valid mood.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validateTaskDuration(int? value) {
    const validDurations = [15, 30, 45, 60, 90, 120];
    if (value == null) {
      return const ValidationResult.invalid('Please select a duration.');
    }
    if (!validDurations.contains(value)) {
      return const ValidationResult.invalid('Please select a valid duration.');
    }
    return const ValidationResult.valid();
  }

  static ValidationResult validateCategory(String? value) {
    const validCategories = ['Academics', 'Group work', 'Admin', 'Wellness', 'Routine', 'Social'];
    if (value == null || value.isEmpty) {
      return const ValidationResult.invalid('Please select a category.');
    }
    if (!validCategories.contains(value)) {
      return const ValidationResult.invalid('Please select a valid category.');
    }
    return const ValidationResult.valid();
  }
}