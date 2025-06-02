function trimObject(obj) {
  if (typeof obj !== "object" || obj === null) {
    return obj;
  }

  if (Array.isArray(obj)) {
    return obj.map(trimObject);
  }

  const trimmedObj = {};

  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const value = obj[key];

      if (typeof value === "string") {
        trimmedObj[key] = value.trim();
      } else if (typeof value === "object") {
        trimmedObj[key] = trimObject(value);
      } else {
        trimmedObj[key] = value;
      }
    }
  }

  return trimmedObj;
}

function findKeyWithEmptyStringValue(obj) {
  for (const key in obj) {
    if (
      obj.hasOwnProperty(key) &&
      typeof obj[key] === "string" &&
      obj[key] === ""
    ) {
      return key;
    }
  }
  return null;
}

function reorderKeys(obj, order) {
  const orderedObj = {};

  order.forEach((key) => {
    if (obj.hasOwnProperty(key)) {
      orderedObj[key] = obj[key];
    }
  });

  // Add the remaining properties not in the order array
  for (const key in obj) {
    if (!orderedObj.hasOwnProperty(key)) {
      orderedObj[key] = obj[key];
    }
  }

  return orderedObj;
}

function convertAbbreviations(dataArray) {
  const genderMapping = {
    M: "Male",
    F: "Female",
    O: "Other",
  };

  const convertedArray = dataArray.map((item) => ({
    ...item,
    gender: genderMapping[item.gender] || item.gender,
  }));

  return convertedArray;
}

module.exports = {
  trimObject,
  findKeyWithEmptyStringValue,
  reorderKeys,
  convertAbbreviations,
};
