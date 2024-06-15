exports.handleError = (error) => {
    console.error(error);
    alert('An error occurred: ' + error.message);
};
