import React from 'react';

const DataForm = ({ setData }) => {
    const handleSubmit = async (event) => {
        event.preventDefault();
        const id = event.target.idInput.value;
        const response = await fetch(`/data?id=${id}`);
        const result = await response.json();
        setData([result]);
    };

    return (
        <form id="dataForm" onSubmit={handleSubmit}>
            <input type="text" name="id" id="idInput" placeholder="Enter ID" required />
            <button type="submit">Get Data from DynamoDB</button>
        </form>
    );
};

export default DataForm;