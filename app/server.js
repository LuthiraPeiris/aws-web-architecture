const express = require("express");
const { Client } = require("pg");
const {
    SecretsManagerClient,
    GetSecretValueCommand
} = require("@aws-sdk/client-secrets-manager");

const app = express();
const PORT = 3000;

const secretsClient = new SecretsManagerClient({
    region: "ap-south-1"
});

const SECRET_ARN = "YOUR_SECRET_ARN";

async function getDatabaseCredentials() {
    const command = new GetSecretValueCommand({
        SecretId: SECRET_ARN
    });

    const response = await secretsClient.send(command);

    return JSON.parse(response.SecretString);
}

app.get("/", async (req, res) => {
    try {
        const credentials = await getDatabaseCredentials();

        const db = new Client({
            host: "aws-web-db.ct6es2iuw8rs.ap-south-1.rds.amazonaws.com",
            port: 5432,
            user: credentials.username,
            password: credentials.password,
            database: "postgres",
            ssl: {
                rejectUnauthorized: false
            }
        });

        await db.connect();

        const result = await db.query(
            "SELECT NOW() AS current_time"
        );

        await db.end();

        res.send(`
            <h1>AWS Web Architecture</h1>
            <p>Node.js application is running successfully.</p>
            <p>Server: EC2</p>
            <p>Database: RDS PostgreSQL</p>
            <p>Database connection: SUCCESS</p>
            <p>Database time: ${result.rows[0].current_time}</p>
        `);

    } catch (error) {
        console.error("Database connection error:", error);

        res.status(500).send(`
            <h1>AWS Web Architecture</h1>
            <p>Application is running.</p>
            <p>Database connection: FAILED</p>
            <p>Check the server logs.</p>
        `);
    }
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Application running on port ${PORT}`);
});