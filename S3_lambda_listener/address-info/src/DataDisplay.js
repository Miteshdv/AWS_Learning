import React from 'react';

const DataDisplay = ({ data }) => {
    if (data.length === 0) {
        return <div>No data available</div>;
    }

    const headers = Object.keys(data[0]);

    return (
        <div id="dataDisplay">
            <table>
                <thead>
                    <tr>
                        {headers.map((header) => (
                            <th key={header}>{header}</th>
                        ))}
                    </tr>
                </thead>
                <tbody>
                    {data.map((item, index) => (
                        <tr key={index}>
                            {headers.map((header) => (
                                <td key={header}>{item[header]}</td>
                            ))}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default DataDisplay;