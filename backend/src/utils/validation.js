// src/utils/validation.js
export const validateNickname = (nickname) => {
  const regex = /^[A-Za-z][A-Za-z0-9_]{0,9}$/;
  return regex.test(nickname);
};

export const validateEmail = (email) => {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
};

export const validateAge = (age) => {
  const ageNum = parseInt(age, 10);
  return ageNum >= 18 && ageNum <= 60;
};

export const validateBio = (bio) => {
  return bio.length <= 150;
};

export const validateGender = (gender) => {
  const validGenders = ['Male', 'Female', 'Gay', 'Lesbian', 'Bisexual'];
  return validGenders.includes(gender);
};

export const validateSkinColor = (skinColor) => {
  const validColors = ['Fair', 'Dark', 'Dusky', 'Brown', 'White'];
  return validColors.includes(skinColor);
};

export const validateProfession = (profession) => {
  const validProfessions = ['Student', 'Working Professional', 'House Wife'];
  return validProfessions.includes(profession);
};

export const validateWeight = (weight) => {
  const weightNum = parseFloat(weight);
  return weightNum > 0 && weightNum < 300;
};

export const validateProfile = (profileData) => {
  const errors = [];

  if (!validateNickname(profileData.nickname)) {
    errors.push('Invalid nickname format (must start with alphabet, max 10 chars)');
  }

  if (!validateAge(profileData.age)) {
    errors.push('Age must be between 18 and 60');
  }

  if (!validateGender(profileData.gender)) {
    errors.push('Invalid gender selection');
  }

  if (!validateSkinColor(profileData.skinColor)) {
    errors.push('Invalid skin color selection');
  }

  if (!validateProfession(profileData.profession)) {
    errors.push('Invalid profession selection');
  }

  if (!validateWeight(profileData.weight)) {
    errors.push('Invalid weight');
  }

  if (!validateBio(profileData.bio)) {
    errors.push('Bio must not exceed 150 characters');
  }

  if (!profileData.location || profileData.location.trim() === '') {
    errors.push('Location is required');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};
