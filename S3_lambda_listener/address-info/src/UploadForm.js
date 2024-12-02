import React from 'react';

const UploadForm = () => {
    const handleSubmit = async (event) => {
        event.preventDefault();
        const formData = new FormData(event.target);
        const response = await fetch('/upload', {
            method: 'POST',
            body: formData,
        });
        const result = await response.text();
        alert(result);
    };

    return (
        <form id="uploadForm" onSubmit={handleSubmit} enctype="multipart/form-data">
            <input type="file" name="file" id="fileInput" required />
            <button type="submit">Upload to S3</button>
        </form>
    );
};

export default UploadForm;